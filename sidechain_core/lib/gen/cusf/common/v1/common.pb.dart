// This is a generated file - do not edit.
//
// Generated from cusf/common/v1/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// / Consensus-encoded hex.
/// / Variable length data uses a length prefix.
class ConsensusHex extends $pb.GeneratedMessage {
  factory ConsensusHex({
    $0.StringValue? hex,
  }) {
    final result = ConsensusHex._();
    if (hex != null) result.hex = hex;
    return result;
  }

  ConsensusHex._();

  factory ConsensusHex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConsensusHex()..mergeFromBuffer(data, registry);
  factory ConsensusHex.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConsensusHex()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConsensusHex',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'),
      createEmptyInstance: ConsensusHex.$_createMessage)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConsensusHex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConsensusHex copyWith(void Function(ConsensusHex) updates) =>
      super.copyWith((message) => updates(message as ConsensusHex)) as ConsensusHex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConsensusHex() / ConsensusHex.new instead')
  static ConsensusHex create() => ConsensusHex._();
  static $pb.GeneratedMessage $_createMessage() => ConsensusHex._();
  @$core.override
  ConsensusHex createEmptyInstance() => ConsensusHex._();
  @$core.pragma('dart2js:noInline')
  static ConsensusHex getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConsensusHex>(ConsensusHex.$_createMessage);
  static ConsensusHex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}

/// / Hex encoding of byte arrays/vectors.
/// / Length prefixes are not used.
class Hex extends $pb.GeneratedMessage {
  factory Hex({
    $0.StringValue? hex,
  }) {
    final result = Hex._();
    if (hex != null) result.hex = hex;
    return result;
  }

  Hex._();

  factory Hex.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hex()..mergeFromBuffer(data, registry);
  factory Hex.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hex()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Hex',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'),
      createEmptyInstance: Hex.$_createMessage)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hex copyWith(void Function(Hex) updates) => super.copyWith((message) => updates(message as Hex)) as Hex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Hex() / Hex.new instead')
  static Hex create() => Hex._();
  static $pb.GeneratedMessage $_createMessage() => Hex._();
  @$core.override
  Hex createEmptyInstance() => Hex._();
  @$core.pragma('dart2js:noInline')
  static Hex getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Hex>(Hex.$_createMessage);
  static Hex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}

/// / Reverse consensus-encoded hex
class ReverseHex extends $pb.GeneratedMessage {
  factory ReverseHex({
    $0.StringValue? hex,
  }) {
    final result = ReverseHex._();
    if (hex != null) result.hex = hex;
    return result;
  }

  ReverseHex._();

  factory ReverseHex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseHex()..mergeFromBuffer(data, registry);
  factory ReverseHex.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseHex()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReverseHex',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.common.v1'),
      createEmptyInstance: ReverseHex.$_createMessage)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'hex', subBuilder: $0.StringValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseHex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseHex copyWith(void Function(ReverseHex) updates) =>
      super.copyWith((message) => updates(message as ReverseHex)) as ReverseHex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReverseHex() / ReverseHex.new instead')
  static ReverseHex create() => ReverseHex._();
  static $pb.GeneratedMessage $_createMessage() => ReverseHex._();
  @$core.override
  ReverseHex createEmptyInstance() => ReverseHex._();
  @$core.pragma('dart2js:noInline')
  static ReverseHex getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseHex>(ReverseHex.$_createMessage);
  static ReverseHex? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get hex => $_getN(0);
  @$pb.TagNumber(1)
  set hex($0.StringValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureHex() => $_ensure(0);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
