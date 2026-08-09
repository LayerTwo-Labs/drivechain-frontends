//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// What the user is about to put on chain.
class NewsAction extends $pb.ProtobufEnum {
  static const NewsAction NEWS_ACTION_UNSPECIFIED = NewsAction._(0, _omitEnumNames ? '' : 'NEWS_ACTION_UNSPECIFIED');
  static const NewsAction NEWS_ACTION_VOTE = NewsAction._(1, _omitEnumNames ? '' : 'NEWS_ACTION_VOTE');
  static const NewsAction NEWS_ACTION_COMMENT = NewsAction._(2, _omitEnumNames ? '' : 'NEWS_ACTION_COMMENT');
  static const NewsAction NEWS_ACTION_STORY = NewsAction._(3, _omitEnumNames ? '' : 'NEWS_ACTION_STORY');

  static const $core.List<NewsAction> values = <NewsAction>[
    NEWS_ACTION_UNSPECIFIED,
    NEWS_ACTION_VOTE,
    NEWS_ACTION_COMMENT,
    NEWS_ACTION_STORY,
  ];

  static final $core.Map<$core.int, NewsAction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NewsAction? valueOf($core.int value) => _byValue[value];

  const NewsAction._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
