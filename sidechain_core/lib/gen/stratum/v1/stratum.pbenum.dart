//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TargetKind extends $pb.ProtobufEnum {
  static const TargetKind TARGET_KIND_UNSPECIFIED = TargetKind._(0, _omitEnumNames ? '' : 'TARGET_KIND_UNSPECIFIED');
  static const TargetKind TARGET_KIND_SOLO = TargetKind._(1, _omitEnumNames ? '' : 'TARGET_KIND_SOLO');
  static const TargetKind TARGET_KIND_POOL = TargetKind._(2, _omitEnumNames ? '' : 'TARGET_KIND_POOL');
  static const TargetKind TARGET_KIND_CUSTOM = TargetKind._(3, _omitEnumNames ? '' : 'TARGET_KIND_CUSTOM');

  static const $core.List<TargetKind> values = <TargetKind> [
    TARGET_KIND_UNSPECIFIED,
    TARGET_KIND_SOLO,
    TARGET_KIND_POOL,
    TARGET_KIND_CUSTOM,
  ];

  static final $core.Map<$core.int, TargetKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TargetKind? valueOf($core.int value) => _byValue[value];

  const TargetKind._($core.int v, $core.String n) : super(v, n);
}

class WorkMode extends $pb.ProtobufEnum {
  static const WorkMode WORK_MODE_UNSPECIFIED = WorkMode._(0, _omitEnumNames ? '' : 'WORK_MODE_UNSPECIFIED');
  static const WorkMode WORK_MODE_LOW = WorkMode._(1, _omitEnumNames ? '' : 'WORK_MODE_LOW');
  static const WorkMode WORK_MODE_MID = WorkMode._(2, _omitEnumNames ? '' : 'WORK_MODE_MID');
  static const WorkMode WORK_MODE_HIGH = WorkMode._(3, _omitEnumNames ? '' : 'WORK_MODE_HIGH');

  static const $core.List<WorkMode> values = <WorkMode> [
    WORK_MODE_UNSPECIFIED,
    WORK_MODE_LOW,
    WORK_MODE_MID,
    WORK_MODE_HIGH,
  ];

  static final $core.Map<$core.int, WorkMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WorkMode? valueOf($core.int value) => _byValue[value];

  const WorkMode._($core.int v, $core.String n) : super(v, n);
}

class HashrateRange extends $pb.ProtobufEnum {
  static const HashrateRange HASHRATE_RANGE_UNSPECIFIED = HashrateRange._(0, _omitEnumNames ? '' : 'HASHRATE_RANGE_UNSPECIFIED');
  static const HashrateRange HASHRATE_RANGE_HOUR = HashrateRange._(1, _omitEnumNames ? '' : 'HASHRATE_RANGE_HOUR');
  static const HashrateRange HASHRATE_RANGE_DAY = HashrateRange._(2, _omitEnumNames ? '' : 'HASHRATE_RANGE_DAY');
  static const HashrateRange HASHRATE_RANGE_WEEK = HashrateRange._(3, _omitEnumNames ? '' : 'HASHRATE_RANGE_WEEK');

  static const $core.List<HashrateRange> values = <HashrateRange> [
    HASHRATE_RANGE_UNSPECIFIED,
    HASHRATE_RANGE_HOUR,
    HASHRATE_RANGE_DAY,
    HASHRATE_RANGE_WEEK,
  ];

  static final $core.Map<$core.int, HashrateRange> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HashrateRange? valueOf($core.int value) => _byValue[value];

  const HashrateRange._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
