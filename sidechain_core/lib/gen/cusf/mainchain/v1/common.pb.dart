// This is a generated file - do not edit.
//
// Generated from cusf/mainchain/v1/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $1;

import '../../common/v1/common.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class OutPoint extends $pb.GeneratedMessage {
  factory OutPoint({
    $0.ReverseHex? txid,
    $1.UInt32Value? vout,
  }) {
    final result = OutPoint._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    return result;
  }

  OutPoint._();

  factory OutPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OutPoint()..mergeFromBuffer(data, registry);
  factory OutPoint.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OutPoint()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OutPoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: OutPoint.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$1.UInt32Value>(2, _omitFieldNames ? '' : 'vout', subBuilder: $1.UInt32Value.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutPoint copyWith(void Function(OutPoint) updates) =>
      super.copyWith((message) => updates(message as OutPoint)) as OutPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OutPoint() / OutPoint.new instead')
  static OutPoint create() => OutPoint._();
  static $pb.GeneratedMessage $_createMessage() => OutPoint._();
  @$core.override
  OutPoint createEmptyInstance() => OutPoint._();
  @$core.pragma('dart2js:noInline')
  static OutPoint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutPoint>(OutPoint.$_createMessage);
  static OutPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureTxid() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.UInt32Value get vout => $_getN(1);
  @$pb.TagNumber(2)
  set vout($1.UInt32Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.UInt32Value ensureVout() => $_ensure(1);
}

class SidechainDeclaration_V0 extends $pb.GeneratedMessage {
  factory SidechainDeclaration_V0({
    $1.StringValue? title,
    $1.StringValue? description,
    $0.ConsensusHex? hashId1,
    $0.Hex? hashId2,
  }) {
    final result = SidechainDeclaration_V0._();
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (hashId1 != null) result.hashId1 = hashId1;
    if (hashId2 != null) result.hashId2 = hashId2;
    return result;
  }

  SidechainDeclaration_V0._();

  factory SidechainDeclaration_V0.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeclaration_V0()..mergeFromBuffer(data, registry);
  factory SidechainDeclaration_V0.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeclaration_V0()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainDeclaration.V0',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SidechainDeclaration_V0.$_createMessage)
    ..aOM<$1.StringValue>(1, _omitFieldNames ? '' : 'title', subBuilder: $1.StringValue.$_createMessage)
    ..aOM<$1.StringValue>(2, _omitFieldNames ? '' : 'description', subBuilder: $1.StringValue.$_createMessage)
    ..aOM<$0.ConsensusHex>(3, _omitFieldNames ? '' : 'hashId1',
        protoName: 'hash_id_1', subBuilder: $0.ConsensusHex.$_createMessage)
    ..aOM<$0.Hex>(4, _omitFieldNames ? '' : 'hashId2', protoName: 'hash_id_2', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeclaration_V0 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeclaration_V0 copyWith(void Function(SidechainDeclaration_V0) updates) =>
      super.copyWith((message) => updates(message as SidechainDeclaration_V0)) as SidechainDeclaration_V0;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainDeclaration_V0() / SidechainDeclaration_V0.new instead')
  static SidechainDeclaration_V0 create() => SidechainDeclaration_V0._();
  static $pb.GeneratedMessage $_createMessage() => SidechainDeclaration_V0._();
  @$core.override
  SidechainDeclaration_V0 createEmptyInstance() => SidechainDeclaration_V0._();
  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration_V0 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SidechainDeclaration_V0>(SidechainDeclaration_V0.$_createMessage);
  static SidechainDeclaration_V0? _defaultInstance;

  @$pb.TagNumber(1)
  $1.StringValue get title => $_getN(0);
  @$pb.TagNumber(1)
  set title($1.StringValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.StringValue ensureTitle() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.StringValue get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($1.StringValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.StringValue ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.ConsensusHex get hashId1 => $_getN(2);
  @$pb.TagNumber(3)
  set hashId1($0.ConsensusHex value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasHashId1() => $_has(2);
  @$pb.TagNumber(3)
  void clearHashId1() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ConsensusHex ensureHashId1() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Hex get hashId2 => $_getN(3);
  @$pb.TagNumber(4)
  set hashId2($0.Hex value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasHashId2() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashId2() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Hex ensureHashId2() => $_ensure(3);
}

enum SidechainDeclaration_SidechainDeclaration { v0, notSet }

class SidechainDeclaration extends $pb.GeneratedMessage {
  factory SidechainDeclaration({
    SidechainDeclaration_V0? v0,
  }) {
    final result = SidechainDeclaration._();
    if (v0 != null) result.v0 = v0;
    return result;
  }

  SidechainDeclaration._();

  factory SidechainDeclaration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeclaration()..mergeFromBuffer(data, registry);
  factory SidechainDeclaration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeclaration()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SidechainDeclaration_SidechainDeclaration>
      _SidechainDeclaration_SidechainDeclarationByTag = {
    1: SidechainDeclaration_SidechainDeclaration.v0,
    0: SidechainDeclaration_SidechainDeclaration.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainDeclaration',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SidechainDeclaration.$_createMessage)
    ..oo(0, [1])
    ..aOM<SidechainDeclaration_V0>(1, _omitFieldNames ? '' : 'v0', subBuilder: SidechainDeclaration_V0.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeclaration clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeclaration copyWith(void Function(SidechainDeclaration) updates) =>
      super.copyWith((message) => updates(message as SidechainDeclaration)) as SidechainDeclaration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainDeclaration() / SidechainDeclaration.new instead')
  static SidechainDeclaration create() => SidechainDeclaration._();
  static $pb.GeneratedMessage $_createMessage() => SidechainDeclaration._();
  @$core.override
  SidechainDeclaration createEmptyInstance() => SidechainDeclaration._();
  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SidechainDeclaration>(SidechainDeclaration.$_createMessage);
  static SidechainDeclaration? _defaultInstance;

  @$pb.TagNumber(1)
  SidechainDeclaration_SidechainDeclaration whichSidechainDeclaration() =>
      _SidechainDeclaration_SidechainDeclarationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  void clearSidechainDeclaration() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SidechainDeclaration_V0 get v0 => $_getN(0);
  @$pb.TagNumber(1)
  set v0(SidechainDeclaration_V0 value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasV0() => $_has(0);
  @$pb.TagNumber(1)
  void clearV0() => $_clearField(1);
  @$pb.TagNumber(1)
  SidechainDeclaration_V0 ensureV0() => $_ensure(0);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
