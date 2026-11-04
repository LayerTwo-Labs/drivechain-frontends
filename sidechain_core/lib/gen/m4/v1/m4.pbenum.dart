// This is a generated file - do not edit.
//
// Generated from m4/v1/m4.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// The vote for a sidechain that has no upvote.
class VotePolicy extends $pb.ProtobufEnum {
  static const VotePolicy VOTE_POLICY_UNSPECIFIED = VotePolicy._(0, _omitEnumNames ? '' : 'VOTE_POLICY_UNSPECIFIED');
  static const VotePolicy VOTE_POLICY_ABSTAIN = VotePolicy._(1, _omitEnumNames ? '' : 'VOTE_POLICY_ABSTAIN');

  /// Upvote the first pending bundle that this enforcer proposed.
  static const VotePolicy VOTE_POLICY_UPVOTE_KNOWN = VotePolicy._(2, _omitEnumNames ? '' : 'VOTE_POLICY_UPVOTE_KNOWN');

  /// Upvote the first pending bundle.
  static const VotePolicy VOTE_POLICY_UPVOTE_ALL = VotePolicy._(3, _omitEnumNames ? '' : 'VOTE_POLICY_UPVOTE_ALL');
  static const VotePolicy VOTE_POLICY_ALARM = VotePolicy._(4, _omitEnumNames ? '' : 'VOTE_POLICY_ALARM');

  static const $core.List<VotePolicy> values = <VotePolicy>[
    VOTE_POLICY_UNSPECIFIED,
    VOTE_POLICY_ABSTAIN,
    VOTE_POLICY_UPVOTE_KNOWN,
    VOTE_POLICY_UPVOTE_ALL,
    VOTE_POLICY_ALARM,
  ];

  static final $core.List<VotePolicy?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static VotePolicy? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const VotePolicy._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
