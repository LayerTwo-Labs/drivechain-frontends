//
//  Generated code. Do not modify.
//  source: health/v1/health.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CheckResponse_Status extends $pb.ProtobufEnum {
  static const CheckResponse_Status STATUS_UNSPECIFIED = CheckResponse_Status._(0, _omitEnumNames ? '' : 'STATUS_UNSPECIFIED');
  static const CheckResponse_Status STATUS_SERVING = CheckResponse_Status._(1, _omitEnumNames ? '' : 'STATUS_SERVING');
  static const CheckResponse_Status STATUS_NOT_SERVING = CheckResponse_Status._(2, _omitEnumNames ? '' : 'STATUS_NOT_SERVING');
  static const CheckResponse_Status STATUS_SERVICE_UNKNOWN = CheckResponse_Status._(3, _omitEnumNames ? '' : 'STATUS_SERVICE_UNKNOWN');

  static const $core.List<CheckResponse_Status> values = <CheckResponse_Status> [
    STATUS_UNSPECIFIED,
    STATUS_SERVING,
    STATUS_NOT_SERVING,
    STATUS_SERVICE_UNKNOWN,
  ];

  static final $core.Map<$core.int, CheckResponse_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CheckResponse_Status? valueOf($core.int value) => _byValue[value];

  const CheckResponse_Status._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
