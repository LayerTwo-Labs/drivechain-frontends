//
//  Generated code. Do not modify.
//  source: cusf/common/v1/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/wrappers.pb.dart' as $0;

/// / Consensus-encoded hex.
/// / Variable length data uses a length prefix.
class ConsensusHex extends $pb.GeneratedMessage {
  factory ConsensusHex({
    $0.StringValue? hex,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  ConsensusHex._() : super();
  factory ConsensusHex.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConsensusHex.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConsensusHex', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'), createEmptyInstance: create)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConsensusHex clone() => ConsensusHex()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConsensusHex copyWith(void Function(ConsensusHex) updates) => super.copyWith((message) => updates(message as ConsensusHex)) as ConsensusHex;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConsensusHex create() => ConsensusHex._();
  ConsensusHex createEmptyInstance() => create();
  static $pb.PbList<ConsensusHex> createRepeated() => $pb.PbList<ConsensusHex>();
  @$core.pragma('dart2js:noInline')
  static ConsensusHex getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConsensusHex>(create);
  static ConsensusHex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}

/// / Hex encoding of byte arrays/vectors.
/// / Length prefixes are not used.
class Hex extends $pb.GeneratedMessage {
  factory Hex({
    $0.StringValue? hex,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  Hex._() : super();
  factory Hex.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Hex.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Hex', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'), createEmptyInstance: create)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Hex clone() => Hex()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Hex copyWith(void Function(Hex) updates) => super.copyWith((message) => updates(message as Hex)) as Hex;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Hex create() => Hex._();
  Hex createEmptyInstance() => create();
  static $pb.PbList<Hex> createRepeated() => $pb.PbList<Hex>();
  @$core.pragma('dart2js:noInline')
  static Hex getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Hex>(create);
  static Hex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}

/// / Reverse consensus-encoded hex
class ReverseHex extends $pb.GeneratedMessage {
  factory ReverseHex({
    $0.StringValue? hex,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  ReverseHex._() : super();
  factory ReverseHex.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReverseHex.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReverseHex', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'), createEmptyInstance: create)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReverseHex clone() => ReverseHex()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReverseHex copyWith(void Function(ReverseHex) updates) => super.copyWith((message) => updates(message as ReverseHex)) as ReverseHex;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseHex create() => ReverseHex._();
  ReverseHex createEmptyInstance() => create();
  static $pb.PbList<ReverseHex> createRepeated() => $pb.PbList<ReverseHex>();
  @$core.pragma('dart2js:noInline')
  static ReverseHex getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseHex>(create);
  static ReverseHex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
