// This is a generated file - do not edit.
//
// Generated from misc/v1/misc.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// What the user is about to put on chain.
class NewsAction extends $pb.ProtobufEnum {
  static const NewsAction NEWS_ACTION_UNSPECIFIED = NewsAction._(0, _omitEnumNames ? '' : 'NEWS_ACTION_UNSPECIFIED');
  static const NewsAction NEWS_ACTION_COMMENT = NewsAction._(2, _omitEnumNames ? '' : 'NEWS_ACTION_COMMENT');
  static const NewsAction NEWS_ACTION_STORY = NewsAction._(3, _omitEnumNames ? '' : 'NEWS_ACTION_STORY');

  static const $core.List<NewsAction> values = <NewsAction>[
    NEWS_ACTION_UNSPECIFIED,
    NEWS_ACTION_COMMENT,
    NEWS_ACTION_STORY,
  ];

  static final $core.List<NewsAction?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static NewsAction? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NewsAction._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
