//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' as $0;

class DispenseCoinsRequest extends $pb.GeneratedMessage {
  factory DispenseCoinsRequest({
    $core.String? destination,
    $core.double? amount,
  }) {
    final $result = create();
    if (destination != null) {
      $result.destination = destination;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  DispenseCoinsRequest._() : super();
  factory DispenseCoinsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DispenseCoinsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DispenseCoinsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'faucet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'destination')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DispenseCoinsRequest clone() => DispenseCoinsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DispenseCoinsRequest copyWith(void Function(DispenseCoinsRequest) updates) => super.copyWith((message) => updates(message as DispenseCoinsRequest)) as DispenseCoinsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DispenseCoinsRequest create() => DispenseCoinsRequest._();
  DispenseCoinsRequest createEmptyInstance() => create();
  static $pb.PbList<DispenseCoinsRequest> createRepeated() => $pb.PbList<DispenseCoinsRequest>();
  @$core.pragma('dart2js:noInline')
  static DispenseCoinsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DispenseCoinsRequest>(create);
  static DispenseCoinsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get destination => $_getSZ(0);
  @$pb.TagNumber(1)
  set destination($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDestination() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestination() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
}

class DispenseCoinsResponse extends $pb.GeneratedMessage {
  factory DispenseCoinsResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  DispenseCoinsResponse._() : super();
  factory DispenseCoinsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DispenseCoinsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DispenseCoinsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'faucet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DispenseCoinsResponse clone() => DispenseCoinsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DispenseCoinsResponse copyWith(void Function(DispenseCoinsResponse) updates) => super.copyWith((message) => updates(message as DispenseCoinsResponse)) as DispenseCoinsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DispenseCoinsResponse create() => DispenseCoinsResponse._();
  DispenseCoinsResponse createEmptyInstance() => create();
  static $pb.PbList<DispenseCoinsResponse> createRepeated() => $pb.PbList<DispenseCoinsResponse>();
  @$core.pragma('dart2js:noInline')
  static DispenseCoinsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DispenseCoinsResponse>(create);
  static DispenseCoinsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ListClaimsRequest extends $pb.GeneratedMessage {
  factory ListClaimsRequest() => create();
  ListClaimsRequest._() : super();
  factory ListClaimsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListClaimsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListClaimsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'faucet.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListClaimsRequest clone() => ListClaimsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListClaimsRequest copyWith(void Function(ListClaimsRequest) updates) => super.copyWith((message) => updates(message as ListClaimsRequest)) as ListClaimsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListClaimsRequest create() => ListClaimsRequest._();
  ListClaimsRequest createEmptyInstance() => create();
  static $pb.PbList<ListClaimsRequest> createRepeated() => $pb.PbList<ListClaimsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListClaimsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListClaimsRequest>(create);
  static ListClaimsRequest? _defaultInstance;
}

class ListClaimsResponse extends $pb.GeneratedMessage {
  factory ListClaimsResponse({
    $core.Iterable<$0.GetTransactionResponse>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListClaimsResponse._() : super();
  factory ListClaimsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListClaimsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListClaimsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'faucet.v1'), createEmptyInstance: create)
    ..pc<$0.GetTransactionResponse>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: $0.GetTransactionResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListClaimsResponse clone() => ListClaimsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListClaimsResponse copyWith(void Function(ListClaimsResponse) updates) => super.copyWith((message) => updates(message as ListClaimsResponse)) as ListClaimsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListClaimsResponse create() => ListClaimsResponse._();
  ListClaimsResponse createEmptyInstance() => create();
  static $pb.PbList<ListClaimsResponse> createRepeated() => $pb.PbList<ListClaimsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListClaimsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListClaimsResponse>(create);
  static ListClaimsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.GetTransactionResponse> get transactions => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
