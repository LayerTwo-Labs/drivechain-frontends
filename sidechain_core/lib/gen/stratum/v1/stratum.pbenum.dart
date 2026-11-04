// This is a generated file - do not edit.
//
// Generated from stratum/v1/stratum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TargetKind extends $pb.ProtobufEnum {
  static const TargetKind TARGET_KIND_UNSPECIFIED = TargetKind._(0, _omitEnumNames ? '' : 'TARGET_KIND_UNSPECIFIED');

  /// This node builds each block from its own template.
  static const TargetKind TARGET_KIND_SOLO = TargetKind._(1, _omitEnumNames ? '' : 'TARGET_KIND_SOLO');

  /// A pool from the network catalog.
  static const TargetKind TARGET_KIND_POOL = TargetKind._(2, _omitEnumNames ? '' : 'TARGET_KIND_POOL');

  /// A Stratum pool the user typed in.
  static const TargetKind TARGET_KIND_CUSTOM = TargetKind._(3, _omitEnumNames ? '' : 'TARGET_KIND_CUSTOM');

  static const $core.List<TargetKind> values = <TargetKind>[
    TARGET_KIND_UNSPECIFIED,
    TARGET_KIND_SOLO,
    TARGET_KIND_POOL,
    TARGET_KIND_CUSTOM,
  ];

  static final $core.List<TargetKind?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TargetKind? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TargetKind._(super.value, super.name);
}

class WorkMode extends $pb.ProtobufEnum {
  static const WorkMode WORK_MODE_UNSPECIFIED = WorkMode._(0, _omitEnumNames ? '' : 'WORK_MODE_UNSPECIFIED');
  static const WorkMode WORK_MODE_LOW = WorkMode._(1, _omitEnumNames ? '' : 'WORK_MODE_LOW');
  static const WorkMode WORK_MODE_MID = WorkMode._(2, _omitEnumNames ? '' : 'WORK_MODE_MID');
  static const WorkMode WORK_MODE_HIGH = WorkMode._(3, _omitEnumNames ? '' : 'WORK_MODE_HIGH');

  static const $core.List<WorkMode> values = <WorkMode>[
    WORK_MODE_UNSPECIFIED,
    WORK_MODE_LOW,
    WORK_MODE_MID,
    WORK_MODE_HIGH,
  ];

  static final $core.List<WorkMode?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static WorkMode? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WorkMode._(super.value, super.name);
}

class HashrateRange extends $pb.ProtobufEnum {
  static const HashrateRange HASHRATE_RANGE_UNSPECIFIED =
      HashrateRange._(0, _omitEnumNames ? '' : 'HASHRATE_RANGE_UNSPECIFIED');

  /// One hour in one-minute buckets.
  static const HashrateRange HASHRATE_RANGE_HOUR = HashrateRange._(1, _omitEnumNames ? '' : 'HASHRATE_RANGE_HOUR');

  /// One day in ten-minute buckets.
  static const HashrateRange HASHRATE_RANGE_DAY = HashrateRange._(2, _omitEnumNames ? '' : 'HASHRATE_RANGE_DAY');

  /// Seven days in one-hour buckets.
  static const HashrateRange HASHRATE_RANGE_WEEK = HashrateRange._(3, _omitEnumNames ? '' : 'HASHRATE_RANGE_WEEK');

  static const $core.List<HashrateRange> values = <HashrateRange>[
    HASHRATE_RANGE_UNSPECIFIED,
    HASHRATE_RANGE_HOUR,
    HASHRATE_RANGE_DAY,
    HASHRATE_RANGE_WEEK,
  ];

  static final $core.List<HashrateRange?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HashrateRange? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HashrateRange._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
