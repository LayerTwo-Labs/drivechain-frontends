// This is a generated file - do not edit.
//
// Generated from utils/v1/utils.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConvertFormat extends $pb.ProtobufEnum {
  static const ConvertFormat CONVERT_FORMAT_AUTO = ConvertFormat._(0, _omitEnumNames ? '' : 'CONVERT_FORMAT_AUTO');
  static const ConvertFormat CONVERT_FORMAT_HEX = ConvertFormat._(1, _omitEnumNames ? '' : 'CONVERT_FORMAT_HEX');
  static const ConvertFormat CONVERT_FORMAT_BASE64 = ConvertFormat._(2, _omitEnumNames ? '' : 'CONVERT_FORMAT_BASE64');
  static const ConvertFormat CONVERT_FORMAT_BASE58 = ConvertFormat._(3, _omitEnumNames ? '' : 'CONVERT_FORMAT_BASE58');
  static const ConvertFormat CONVERT_FORMAT_BASE58CHECK =
      ConvertFormat._(4, _omitEnumNames ? '' : 'CONVERT_FORMAT_BASE58CHECK');
  static const ConvertFormat CONVERT_FORMAT_BECH32 = ConvertFormat._(5, _omitEnumNames ? '' : 'CONVERT_FORMAT_BECH32');
  static const ConvertFormat CONVERT_FORMAT_ASCII = ConvertFormat._(6, _omitEnumNames ? '' : 'CONVERT_FORMAT_ASCII');
  static const ConvertFormat CONVERT_FORMAT_WIF = ConvertFormat._(7, _omitEnumNames ? '' : 'CONVERT_FORMAT_WIF');
  static const ConvertFormat CONVERT_FORMAT_PASSPHRASE =
      ConvertFormat._(8, _omitEnumNames ? '' : 'CONVERT_FORMAT_PASSPHRASE');

  static const $core.List<ConvertFormat> values = <ConvertFormat>[
    CONVERT_FORMAT_AUTO,
    CONVERT_FORMAT_HEX,
    CONVERT_FORMAT_BASE64,
    CONVERT_FORMAT_BASE58,
    CONVERT_FORMAT_BASE58CHECK,
    CONVERT_FORMAT_BECH32,
    CONVERT_FORMAT_ASCII,
    CONVERT_FORMAT_WIF,
    CONVERT_FORMAT_PASSPHRASE,
  ];

  static final $core.List<ConvertFormat?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 8);
  static ConvertFormat? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConvertFormat._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
