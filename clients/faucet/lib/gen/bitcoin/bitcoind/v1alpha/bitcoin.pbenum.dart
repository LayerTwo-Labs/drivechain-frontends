//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetTransactionResponse_Replaceable extends $pb.ProtobufEnum {
  static const GetTransactionResponse_Replaceable REPLACEABLE_UNSPECIFIED = GetTransactionResponse_Replaceable._(0, _omitEnumNames ? '' : 'REPLACEABLE_UNSPECIFIED');
  static const GetTransactionResponse_Replaceable REPLACEABLE_YES = GetTransactionResponse_Replaceable._(1, _omitEnumNames ? '' : 'REPLACEABLE_YES');
  static const GetTransactionResponse_Replaceable REPLACEABLE_NO = GetTransactionResponse_Replaceable._(2, _omitEnumNames ? '' : 'REPLACEABLE_NO');

  static const $core.List<GetTransactionResponse_Replaceable> values = <GetTransactionResponse_Replaceable> [
    REPLACEABLE_UNSPECIFIED,
    REPLACEABLE_YES,
    REPLACEABLE_NO,
  ];

  static final $core.Map<$core.int, GetTransactionResponse_Replaceable> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetTransactionResponse_Replaceable? valueOf($core.int value) => _byValue[value];

  const GetTransactionResponse_Replaceable._($core.int v, $core.String n) : super(v, n);
}

class GetTransactionResponse_Category extends $pb.ProtobufEnum {
  static const GetTransactionResponse_Category CATEGORY_UNSPECIFIED = GetTransactionResponse_Category._(0, _omitEnumNames ? '' : 'CATEGORY_UNSPECIFIED');
  static const GetTransactionResponse_Category CATEGORY_SEND = GetTransactionResponse_Category._(1, _omitEnumNames ? '' : 'CATEGORY_SEND');
  static const GetTransactionResponse_Category CATEGORY_RECEIVE = GetTransactionResponse_Category._(2, _omitEnumNames ? '' : 'CATEGORY_RECEIVE');
  static const GetTransactionResponse_Category CATEGORY_GENERATE = GetTransactionResponse_Category._(3, _omitEnumNames ? '' : 'CATEGORY_GENERATE');
  static const GetTransactionResponse_Category CATEGORY_IMMATURE = GetTransactionResponse_Category._(4, _omitEnumNames ? '' : 'CATEGORY_IMMATURE');
  static const GetTransactionResponse_Category CATEGORY_ORPHAN = GetTransactionResponse_Category._(5, _omitEnumNames ? '' : 'CATEGORY_ORPHAN');

  static const $core.List<GetTransactionResponse_Category> values = <GetTransactionResponse_Category> [
    CATEGORY_UNSPECIFIED,
    CATEGORY_SEND,
    CATEGORY_RECEIVE,
    CATEGORY_GENERATE,
    CATEGORY_IMMATURE,
    CATEGORY_ORPHAN,
  ];

  static final $core.Map<$core.int, GetTransactionResponse_Category> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetTransactionResponse_Category? valueOf($core.int value) => _byValue[value];

  const GetTransactionResponse_Category._($core.int v, $core.String n) : super(v, n);
}

class EstimateSmartFeeRequest_EstimateMode extends $pb.ProtobufEnum {
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_UNSPECIFIED = EstimateSmartFeeRequest_EstimateMode._(0, _omitEnumNames ? '' : 'ESTIMATE_MODE_UNSPECIFIED');
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_ECONOMICAL = EstimateSmartFeeRequest_EstimateMode._(1, _omitEnumNames ? '' : 'ESTIMATE_MODE_ECONOMICAL');
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_CONSERVATIVE = EstimateSmartFeeRequest_EstimateMode._(2, _omitEnumNames ? '' : 'ESTIMATE_MODE_CONSERVATIVE');

  static const $core.List<EstimateSmartFeeRequest_EstimateMode> values = <EstimateSmartFeeRequest_EstimateMode> [
    ESTIMATE_MODE_UNSPECIFIED,
    ESTIMATE_MODE_ECONOMICAL,
    ESTIMATE_MODE_CONSERVATIVE,
  ];

  static final $core.Map<$core.int, EstimateSmartFeeRequest_EstimateMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static EstimateSmartFeeRequest_EstimateMode? valueOf($core.int value) => _byValue[value];

  const EstimateSmartFeeRequest_EstimateMode._($core.int v, $core.String n) : super(v, n);
}

class GetBlockRequest_Verbosity extends $pb.ProtobufEnum {
  static const GetBlockRequest_Verbosity VERBOSITY_UNSPECIFIED = GetBlockRequest_Verbosity._(0, _omitEnumNames ? '' : 'VERBOSITY_UNSPECIFIED');
  static const GetBlockRequest_Verbosity VERBOSITY_RAW_DATA = GetBlockRequest_Verbosity._(1, _omitEnumNames ? '' : 'VERBOSITY_RAW_DATA');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_INFO = GetBlockRequest_Verbosity._(2, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_INFO');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_INFO = GetBlockRequest_Verbosity._(3, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_INFO');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_PREVOUT_INFO = GetBlockRequest_Verbosity._(4, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_PREVOUT_INFO');

  static const $core.List<GetBlockRequest_Verbosity> values = <GetBlockRequest_Verbosity> [
    VERBOSITY_UNSPECIFIED,
    VERBOSITY_RAW_DATA,
    VERBOSITY_BLOCK_INFO,
    VERBOSITY_BLOCK_TX_INFO,
    VERBOSITY_BLOCK_TX_PREVOUT_INFO,
  ];

  static final $core.Map<$core.int, GetBlockRequest_Verbosity> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetBlockRequest_Verbosity? valueOf($core.int value) => _byValue[value];

  const GetBlockRequest_Verbosity._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
