//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// The vote for a sidechain that has no upvote.
class VotePolicy extends $pb.ProtobufEnum {
  static const VotePolicy VOTE_POLICY_UNSPECIFIED = VotePolicy._(0, _omitEnumNames ? '' : 'VOTE_POLICY_UNSPECIFIED');
  static const VotePolicy VOTE_POLICY_ABSTAIN = VotePolicy._(1, _omitEnumNames ? '' : 'VOTE_POLICY_ABSTAIN');
  static const VotePolicy VOTE_POLICY_UPVOTE_KNOWN = VotePolicy._(2, _omitEnumNames ? '' : 'VOTE_POLICY_UPVOTE_KNOWN');
  static const VotePolicy VOTE_POLICY_UPVOTE_ALL = VotePolicy._(3, _omitEnumNames ? '' : 'VOTE_POLICY_UPVOTE_ALL');
  static const VotePolicy VOTE_POLICY_ALARM = VotePolicy._(4, _omitEnumNames ? '' : 'VOTE_POLICY_ALARM');

  static const $core.List<VotePolicy> values = <VotePolicy> [
    VOTE_POLICY_UNSPECIFIED,
    VOTE_POLICY_ABSTAIN,
    VOTE_POLICY_UPVOTE_KNOWN,
    VOTE_POLICY_UPVOTE_ALL,
    VOTE_POLICY_ALARM,
  ];

  static final $core.Map<$core.int, VotePolicy> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VotePolicy? valueOf($core.int value) => _byValue[value];

  const VotePolicy._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
