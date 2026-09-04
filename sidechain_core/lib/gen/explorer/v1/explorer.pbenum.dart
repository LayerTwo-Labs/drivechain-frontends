//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Kind names what a row is. A deposit never appears in a block body, so a feed
/// of transactions alone misses it.
class Kind extends $pb.ProtobufEnum {
  static const Kind KIND_UNSPECIFIED = Kind._(0, _omitEnumNames ? '' : 'KIND_UNSPECIFIED');
  static const Kind KIND_TRANSFER = Kind._(1, _omitEnumNames ? '' : 'KIND_TRANSFER');
  static const Kind KIND_WITHDRAWAL = Kind._(2, _omitEnumNames ? '' : 'KIND_WITHDRAWAL');
  static const Kind KIND_DEPOSIT = Kind._(3, _omitEnumNames ? '' : 'KIND_DEPOSIT');

  static const $core.List<Kind> values = <Kind> [
    KIND_UNSPECIFIED,
    KIND_TRANSFER,
    KIND_WITHDRAWAL,
    KIND_DEPOSIT,
  ];

  static final $core.Map<$core.int, Kind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Kind? valueOf($core.int value) => _byValue[value];

  const Kind._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
