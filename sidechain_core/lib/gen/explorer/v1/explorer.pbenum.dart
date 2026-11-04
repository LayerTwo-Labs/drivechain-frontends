// This is a generated file - do not edit.
//
// Generated from explorer/v1/explorer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Kind names what a row is. A deposit never appears in a block body, so a feed
/// of transactions alone misses it.
class Kind extends $pb.ProtobufEnum {
  static const Kind KIND_UNSPECIFIED = Kind._(0, _omitEnumNames ? '' : 'KIND_UNSPECIFIED');
  static const Kind KIND_TRANSFER = Kind._(1, _omitEnumNames ? '' : 'KIND_TRANSFER');
  static const Kind KIND_WITHDRAWAL = Kind._(2, _omitEnumNames ? '' : 'KIND_WITHDRAWAL');
  static const Kind KIND_DEPOSIT = Kind._(3, _omitEnumNames ? '' : 'KIND_DEPOSIT');

  static const $core.List<Kind> values = <Kind>[
    KIND_UNSPECIFIED,
    KIND_TRANSFER,
    KIND_WITHDRAWAL,
    KIND_DEPOSIT,
  ];

  static final $core.List<Kind?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Kind? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Kind._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
