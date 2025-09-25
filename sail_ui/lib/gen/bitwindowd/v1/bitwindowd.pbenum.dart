//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Direction extends $pb.ProtobufEnum {
  static const Direction DIRECTION_UNSPECIFIED = Direction._(0, _omitEnumNames ? '' : 'DIRECTION_UNSPECIFIED');
  static const Direction DIRECTION_SEND = Direction._(1, _omitEnumNames ? '' : 'DIRECTION_SEND');
  static const Direction DIRECTION_RECEIVE = Direction._(2, _omitEnumNames ? '' : 'DIRECTION_RECEIVE');

  static const $core.List<Direction> values = <Direction>[
    DIRECTION_UNSPECIFIED,
    DIRECTION_SEND,
    DIRECTION_RECEIVE,
  ];

  static final $core.Map<$core.int, Direction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Direction? valueOf($core.int value) => _byValue[value];

  const Direction._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
