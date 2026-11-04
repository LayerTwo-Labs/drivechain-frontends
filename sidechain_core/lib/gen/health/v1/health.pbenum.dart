// This is a generated file - do not edit.
//
// Generated from health/v1/health.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CheckResponse_Status extends $pb.ProtobufEnum {
  static const CheckResponse_Status STATUS_UNSPECIFIED =
      CheckResponse_Status._(0, _omitEnumNames ? '' : 'STATUS_UNSPECIFIED');
  static const CheckResponse_Status STATUS_SERVING = CheckResponse_Status._(1, _omitEnumNames ? '' : 'STATUS_SERVING');
  static const CheckResponse_Status STATUS_NOT_SERVING =
      CheckResponse_Status._(2, _omitEnumNames ? '' : 'STATUS_NOT_SERVING');
  static const CheckResponse_Status STATUS_SERVICE_UNKNOWN =
      CheckResponse_Status._(3, _omitEnumNames ? '' : 'STATUS_SERVICE_UNKNOWN');

  static const $core.List<CheckResponse_Status> values = <CheckResponse_Status>[
    STATUS_UNSPECIFIED,
    STATUS_SERVING,
    STATUS_NOT_SERVING,
    STATUS_SERVICE_UNKNOWN,
  ];

  static final $core.List<CheckResponse_Status?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static CheckResponse_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CheckResponse_Status._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
