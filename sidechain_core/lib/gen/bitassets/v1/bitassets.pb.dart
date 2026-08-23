//
//  Generated code. Do not modify.
//  source: bitassets/v1/bitassets.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest() => create();
  GetBalanceRequest._() : super();
  factory GetBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceRequest clone() => GetBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceRequest copyWith(void Function(GetBalanceRequest) updates) => super.copyWith((message) => updates(message as GetBalanceRequest)) as GetBalanceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest create() => GetBalanceRequest._();
  GetBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<GetBalanceRequest> createRepeated() => $pb.PbList<GetBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceRequest>(create);
  static GetBalanceRequest? _defaultInstance;
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $fixnum.Int64? totalSats,
    $fixnum.Int64? availableSats,
  }) {
    final $result = create();
    if (totalSats != null) {
      $result.totalSats = totalSats;
    }
    if (availableSats != null) {
      $result.availableSats = availableSats;
    }
    return $result;
  }
  GetBalanceResponse._() : super();
  factory GetBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalSats')
    ..aInt64(2, _omitFieldNames ? '' : 'availableSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceResponse clone() => GetBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceResponse copyWith(void Function(GetBalanceResponse) updates) => super.copyWith((message) => updates(message as GetBalanceResponse)) as GetBalanceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse create() => GetBalanceResponse._();
  GetBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<GetBalanceResponse> createRepeated() => $pb.PbList<GetBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceResponse>(create);
  static GetBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalSats => $_getI64(0);
  @$pb.TagNumber(1)
  set totalSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTotalSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get availableSats => $_getI64(1);
  @$pb.TagNumber(2)
  set availableSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvailableSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableSats() => clearField(2);
}

class GetBlockCountRequest extends $pb.GeneratedMessage {
  factory GetBlockCountRequest() => create();
  GetBlockCountRequest._() : super();
  factory GetBlockCountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockCountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockCountRequest clone() => GetBlockCountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockCountRequest copyWith(void Function(GetBlockCountRequest) updates) => super.copyWith((message) => updates(message as GetBlockCountRequest)) as GetBlockCountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockCountRequest create() => GetBlockCountRequest._();
  GetBlockCountRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockCountRequest> createRepeated() => $pb.PbList<GetBlockCountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockCountRequest>(create);
  static GetBlockCountRequest? _defaultInstance;
}

class GetBlockCountResponse extends $pb.GeneratedMessage {
  factory GetBlockCountResponse({
    $fixnum.Int64? count,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  GetBlockCountResponse._() : super();
  factory GetBlockCountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockCountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockCountResponse clone() => GetBlockCountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockCountResponse copyWith(void Function(GetBlockCountResponse) updates) => super.copyWith((message) => updates(message as GetBlockCountResponse)) as GetBlockCountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockCountResponse create() => GetBlockCountResponse._();
  GetBlockCountResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockCountResponse> createRepeated() => $pb.PbList<GetBlockCountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockCountResponse>(create);
  static GetBlockCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => clearField(1);
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest() => create();
  StopRequest._() : super();
  factory StopRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopRequest clone() => StopRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopRequest copyWith(void Function(StopRequest) updates) => super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopRequest create() => StopRequest._();
  StopRequest createEmptyInstance() => create();
  static $pb.PbList<StopRequest> createRepeated() => $pb.PbList<StopRequest>();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(create);
  static StopRequest? _defaultInstance;
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => create();
  StopResponse._() : super();
  factory StopResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopResponse clone() => StopResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopResponse copyWith(void Function(StopResponse) updates) => super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopResponse create() => StopResponse._();
  StopResponse createEmptyInstance() => create();
  static $pb.PbList<StopResponse> createRepeated() => $pb.PbList<StopResponse>();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(create);
  static StopResponse? _defaultInstance;
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest() => create();
  GetNewAddressRequest._() : super();
  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest clone() => GetNewAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) => super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  GetNewAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressRequest> createRepeated() => $pb.PbList<GetNewAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(create);
  static GetNewAddressRequest? _defaultInstance;
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetNewAddressResponse._() : super();
  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse clone() => GetNewAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) => super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  GetNewAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressResponse> createRepeated() => $pb.PbList<GetNewAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(create);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class WithdrawRequest extends $pb.GeneratedMessage {
  factory WithdrawRequest({
    $core.String? address,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? sideFeeSats,
    $fixnum.Int64? mainFeeSats,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (sideFeeSats != null) {
      $result.sideFeeSats = sideFeeSats;
    }
    if (mainFeeSats != null) {
      $result.mainFeeSats = mainFeeSats;
    }
    return $result;
  }
  WithdrawRequest._() : super();
  factory WithdrawRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'sideFeeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'mainFeeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawRequest clone() => WithdrawRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawRequest copyWith(void Function(WithdrawRequest) updates) => super.copyWith((message) => updates(message as WithdrawRequest)) as WithdrawRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawRequest create() => WithdrawRequest._();
  WithdrawRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawRequest> createRepeated() => $pb.PbList<WithdrawRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawRequest>(create);
  static WithdrawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sideFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set sideFeeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSideFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearSideFeeSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get mainFeeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set mainFeeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMainFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearMainFeeSats() => clearField(4);
}

class WithdrawResponse extends $pb.GeneratedMessage {
  factory WithdrawResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  WithdrawResponse._() : super();
  factory WithdrawResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawResponse clone() => WithdrawResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawResponse copyWith(void Function(WithdrawResponse) updates) => super.copyWith((message) => updates(message as WithdrawResponse)) as WithdrawResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawResponse create() => WithdrawResponse._();
  WithdrawResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawResponse> createRepeated() => $pb.PbList<WithdrawResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawResponse>(create);
  static WithdrawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class TransferRequest extends $pb.GeneratedMessage {
  factory TransferRequest({
    $core.String? address,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSats,
    $core.String? memo,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (memo != null) {
      $result.memo = memo;
    }
    return $result;
  }
  TransferRequest._() : super();
  factory TransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferRequest clone() => TransferRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferRequest copyWith(void Function(TransferRequest) updates) => super.copyWith((message) => updates(message as TransferRequest)) as TransferRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferRequest create() => TransferRequest._();
  TransferRequest createEmptyInstance() => create();
  static $pb.PbList<TransferRequest> createRepeated() => $pb.PbList<TransferRequest>();
  @$core.pragma('dart2js:noInline')
  static TransferRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferRequest>(create);
  static TransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get memo => $_getSZ(3);
  @$pb.TagNumber(4)
  set memo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMemo() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemo() => clearField(4);
}

class TransferResponse extends $pb.GeneratedMessage {
  factory TransferResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TransferResponse._() : super();
  factory TransferResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferResponse clone() => TransferResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferResponse copyWith(void Function(TransferResponse) updates) => super.copyWith((message) => updates(message as TransferResponse)) as TransferResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferResponse create() => TransferResponse._();
  TransferResponse createEmptyInstance() => create();
  static $pb.PbList<TransferResponse> createRepeated() => $pb.PbList<TransferResponse>();
  @$core.pragma('dart2js:noInline')
  static TransferResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferResponse>(create);
  static TransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetSidechainWealthRequest extends $pb.GeneratedMessage {
  factory GetSidechainWealthRequest() => create();
  GetSidechainWealthRequest._() : super();
  factory GetSidechainWealthRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainWealthRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainWealthRequest clone() => GetSidechainWealthRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainWealthRequest copyWith(void Function(GetSidechainWealthRequest) updates) => super.copyWith((message) => updates(message as GetSidechainWealthRequest)) as GetSidechainWealthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthRequest create() => GetSidechainWealthRequest._();
  GetSidechainWealthRequest createEmptyInstance() => create();
  static $pb.PbList<GetSidechainWealthRequest> createRepeated() => $pb.PbList<GetSidechainWealthRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainWealthRequest>(create);
  static GetSidechainWealthRequest? _defaultInstance;
}

class GetSidechainWealthResponse extends $pb.GeneratedMessage {
  factory GetSidechainWealthResponse({
    $fixnum.Int64? sats,
  }) {
    final $result = create();
    if (sats != null) {
      $result.sats = sats;
    }
    return $result;
  }
  GetSidechainWealthResponse._() : super();
  factory GetSidechainWealthResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainWealthResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainWealthResponse clone() => GetSidechainWealthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainWealthResponse copyWith(void Function(GetSidechainWealthResponse) updates) => super.copyWith((message) => updates(message as GetSidechainWealthResponse)) as GetSidechainWealthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthResponse create() => GetSidechainWealthResponse._();
  GetSidechainWealthResponse createEmptyInstance() => create();
  static $pb.PbList<GetSidechainWealthResponse> createRepeated() => $pb.PbList<GetSidechainWealthResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainWealthResponse>(create);
  static GetSidechainWealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sats => $_getI64(0);
  @$pb.TagNumber(1)
  set sats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearSats() => clearField(1);
}

class CreateDepositRequest extends $pb.GeneratedMessage {
  factory CreateDepositRequest({
    $core.String? address,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  CreateDepositRequest._() : super();
  factory CreateDepositRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDepositRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDepositRequest clone() => CreateDepositRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDepositRequest copyWith(void Function(CreateDepositRequest) updates) => super.copyWith((message) => updates(message as CreateDepositRequest)) as CreateDepositRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDepositRequest create() => CreateDepositRequest._();
  CreateDepositRequest createEmptyInstance() => create();
  static $pb.PbList<CreateDepositRequest> createRepeated() => $pb.PbList<CreateDepositRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateDepositRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDepositRequest>(create);
  static CreateDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => clearField(3);
}

class CreateDepositResponse extends $pb.GeneratedMessage {
  factory CreateDepositResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateDepositResponse._() : super();
  factory CreateDepositResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDepositResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDepositResponse clone() => CreateDepositResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDepositResponse copyWith(void Function(CreateDepositResponse) updates) => super.copyWith((message) => updates(message as CreateDepositResponse)) as CreateDepositResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDepositResponse create() => CreateDepositResponse._();
  CreateDepositResponse createEmptyInstance() => create();
  static $pb.PbList<CreateDepositResponse> createRepeated() => $pb.PbList<CreateDepositResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateDepositResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDepositResponse>(create);
  static CreateDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetPendingWithdrawalBundleRequest extends $pb.GeneratedMessage {
  factory GetPendingWithdrawalBundleRequest() => create();
  GetPendingWithdrawalBundleRequest._() : super();
  factory GetPendingWithdrawalBundleRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPendingWithdrawalBundleRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPendingWithdrawalBundleRequest clone() => GetPendingWithdrawalBundleRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPendingWithdrawalBundleRequest copyWith(void Function(GetPendingWithdrawalBundleRequest) updates) => super.copyWith((message) => updates(message as GetPendingWithdrawalBundleRequest)) as GetPendingWithdrawalBundleRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleRequest create() => GetPendingWithdrawalBundleRequest._();
  GetPendingWithdrawalBundleRequest createEmptyInstance() => create();
  static $pb.PbList<GetPendingWithdrawalBundleRequest> createRepeated() => $pb.PbList<GetPendingWithdrawalBundleRequest>();
  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingWithdrawalBundleRequest>(create);
  static GetPendingWithdrawalBundleRequest? _defaultInstance;
}

class GetPendingWithdrawalBundleResponse extends $pb.GeneratedMessage {
  factory GetPendingWithdrawalBundleResponse({
    $core.String? bundleJson,
  }) {
    final $result = create();
    if (bundleJson != null) {
      $result.bundleJson = bundleJson;
    }
    return $result;
  }
  GetPendingWithdrawalBundleResponse._() : super();
  factory GetPendingWithdrawalBundleResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPendingWithdrawalBundleResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'bundleJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPendingWithdrawalBundleResponse clone() => GetPendingWithdrawalBundleResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPendingWithdrawalBundleResponse copyWith(void Function(GetPendingWithdrawalBundleResponse) updates) => super.copyWith((message) => updates(message as GetPendingWithdrawalBundleResponse)) as GetPendingWithdrawalBundleResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleResponse create() => GetPendingWithdrawalBundleResponse._();
  GetPendingWithdrawalBundleResponse createEmptyInstance() => create();
  static $pb.PbList<GetPendingWithdrawalBundleResponse> createRepeated() => $pb.PbList<GetPendingWithdrawalBundleResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingWithdrawalBundleResponse>(create);
  static GetPendingWithdrawalBundleResponse? _defaultInstance;

  /// JSON string of the bundle, empty if none.
  @$pb.TagNumber(1)
  $core.String get bundleJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bundleJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBundleJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBundleJson() => clearField(1);
}

class ConnectPeerRequest extends $pb.GeneratedMessage {
  factory ConnectPeerRequest({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  ConnectPeerRequest._() : super();
  factory ConnectPeerRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnectPeerRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnectPeerRequest clone() => ConnectPeerRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnectPeerRequest copyWith(void Function(ConnectPeerRequest) updates) => super.copyWith((message) => updates(message as ConnectPeerRequest)) as ConnectPeerRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectPeerRequest create() => ConnectPeerRequest._();
  ConnectPeerRequest createEmptyInstance() => create();
  static $pb.PbList<ConnectPeerRequest> createRepeated() => $pb.PbList<ConnectPeerRequest>();
  @$core.pragma('dart2js:noInline')
  static ConnectPeerRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectPeerRequest>(create);
  static ConnectPeerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class ConnectPeerResponse extends $pb.GeneratedMessage {
  factory ConnectPeerResponse() => create();
  ConnectPeerResponse._() : super();
  factory ConnectPeerResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnectPeerResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnectPeerResponse clone() => ConnectPeerResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnectPeerResponse copyWith(void Function(ConnectPeerResponse) updates) => super.copyWith((message) => updates(message as ConnectPeerResponse)) as ConnectPeerResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectPeerResponse create() => ConnectPeerResponse._();
  ConnectPeerResponse createEmptyInstance() => create();
  static $pb.PbList<ConnectPeerResponse> createRepeated() => $pb.PbList<ConnectPeerResponse>();
  @$core.pragma('dart2js:noInline')
  static ConnectPeerResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectPeerResponse>(create);
  static ConnectPeerResponse? _defaultInstance;
}

class ForgetPeerRequest extends $pb.GeneratedMessage {
  factory ForgetPeerRequest({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  ForgetPeerRequest._() : super();
  factory ForgetPeerRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ForgetPeerRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ForgetPeerRequest clone() => ForgetPeerRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ForgetPeerRequest copyWith(void Function(ForgetPeerRequest) updates) => super.copyWith((message) => updates(message as ForgetPeerRequest)) as ForgetPeerRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForgetPeerRequest create() => ForgetPeerRequest._();
  ForgetPeerRequest createEmptyInstance() => create();
  static $pb.PbList<ForgetPeerRequest> createRepeated() => $pb.PbList<ForgetPeerRequest>();
  @$core.pragma('dart2js:noInline')
  static ForgetPeerRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForgetPeerRequest>(create);
  static ForgetPeerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class ForgetPeerResponse extends $pb.GeneratedMessage {
  factory ForgetPeerResponse() => create();
  ForgetPeerResponse._() : super();
  factory ForgetPeerResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ForgetPeerResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ForgetPeerResponse clone() => ForgetPeerResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ForgetPeerResponse copyWith(void Function(ForgetPeerResponse) updates) => super.copyWith((message) => updates(message as ForgetPeerResponse)) as ForgetPeerResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForgetPeerResponse create() => ForgetPeerResponse._();
  ForgetPeerResponse createEmptyInstance() => create();
  static $pb.PbList<ForgetPeerResponse> createRepeated() => $pb.PbList<ForgetPeerResponse>();
  @$core.pragma('dart2js:noInline')
  static ForgetPeerResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForgetPeerResponse>(create);
  static ForgetPeerResponse? _defaultInstance;
}

class ListPeersRequest extends $pb.GeneratedMessage {
  factory ListPeersRequest() => create();
  ListPeersRequest._() : super();
  factory ListPeersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPeersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListPeersRequest clone() => ListPeersRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListPeersRequest copyWith(void Function(ListPeersRequest) updates) => super.copyWith((message) => updates(message as ListPeersRequest)) as ListPeersRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPeersRequest create() => ListPeersRequest._();
  ListPeersRequest createEmptyInstance() => create();
  static $pb.PbList<ListPeersRequest> createRepeated() => $pb.PbList<ListPeersRequest>();
  @$core.pragma('dart2js:noInline')
  static ListPeersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPeersRequest>(create);
  static ListPeersRequest? _defaultInstance;
}

class ListPeersResponse extends $pb.GeneratedMessage {
  factory ListPeersResponse({
    $core.String? peersJson,
  }) {
    final $result = create();
    if (peersJson != null) {
      $result.peersJson = peersJson;
    }
    return $result;
  }
  ListPeersResponse._() : super();
  factory ListPeersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPeersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'peersJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListPeersResponse clone() => ListPeersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListPeersResponse copyWith(void Function(ListPeersResponse) updates) => super.copyWith((message) => updates(message as ListPeersResponse)) as ListPeersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPeersResponse create() => ListPeersResponse._();
  ListPeersResponse createEmptyInstance() => create();
  static $pb.PbList<ListPeersResponse> createRepeated() => $pb.PbList<ListPeersResponse>();
  @$core.pragma('dart2js:noInline')
  static ListPeersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPeersResponse>(create);
  static ListPeersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get peersJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set peersJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeersJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeersJson() => clearField(1);
}

class MineRequest extends $pb.GeneratedMessage {
  factory MineRequest({
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  MineRequest._() : super();
  factory MineRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MineRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MineRequest clone() => MineRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MineRequest copyWith(void Function(MineRequest) updates) => super.copyWith((message) => updates(message as MineRequest)) as MineRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MineRequest create() => MineRequest._();
  MineRequest createEmptyInstance() => create();
  static $pb.PbList<MineRequest> createRepeated() => $pb.PbList<MineRequest>();
  @$core.pragma('dart2js:noInline')
  static MineRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineRequest>(create);
  static MineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => clearField(1);
}

class MineResponse extends $pb.GeneratedMessage {
  factory MineResponse({
    $core.String? bmmResultJson,
  }) {
    final $result = create();
    if (bmmResultJson != null) {
      $result.bmmResultJson = bmmResultJson;
    }
    return $result;
  }
  MineResponse._() : super();
  factory MineResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MineResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'bmmResultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MineResponse clone() => MineResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MineResponse copyWith(void Function(MineResponse) updates) => super.copyWith((message) => updates(message as MineResponse)) as MineResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MineResponse create() => MineResponse._();
  MineResponse createEmptyInstance() => create();
  static $pb.PbList<MineResponse> createRepeated() => $pb.PbList<MineResponse>();
  @$core.pragma('dart2js:noInline')
  static MineResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineResponse>(create);
  static MineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bmmResultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bmmResultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBmmResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBmmResultJson() => clearField(1);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? hash,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  GetBlockRequest._() : super();
  factory GetBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockRequest clone() => GetBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) => super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockRequest create() => GetBlockRequest._();
  GetBlockRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockRequest> createRepeated() => $pb.PbList<GetBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(create);
  static GetBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    $core.String? blockJson,
  }) {
    final $result = create();
    if (blockJson != null) {
      $result.blockJson = blockJson;
    }
    return $result;
  }
  GetBlockResponse._() : super();
  factory GetBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockResponse clone() => GetBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) => super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockResponse create() => GetBlockResponse._();
  GetBlockResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockResponse> createRepeated() => $pb.PbList<GetBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(create);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockJson() => clearField(1);
}

class GetBestMainchainBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBestMainchainBlockHashRequest() => create();
  GetBestMainchainBlockHashRequest._() : super();
  factory GetBestMainchainBlockHashRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBestMainchainBlockHashRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBestMainchainBlockHashRequest clone() => GetBestMainchainBlockHashRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBestMainchainBlockHashRequest copyWith(void Function(GetBestMainchainBlockHashRequest) updates) => super.copyWith((message) => updates(message as GetBestMainchainBlockHashRequest)) as GetBestMainchainBlockHashRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashRequest create() => GetBestMainchainBlockHashRequest._();
  GetBestMainchainBlockHashRequest createEmptyInstance() => create();
  static $pb.PbList<GetBestMainchainBlockHashRequest> createRepeated() => $pb.PbList<GetBestMainchainBlockHashRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestMainchainBlockHashRequest>(create);
  static GetBestMainchainBlockHashRequest? _defaultInstance;
}

class GetBestMainchainBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBestMainchainBlockHashResponse({
    $core.String? hash,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  GetBestMainchainBlockHashResponse._() : super();
  factory GetBestMainchainBlockHashResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBestMainchainBlockHashResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBestMainchainBlockHashResponse clone() => GetBestMainchainBlockHashResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBestMainchainBlockHashResponse copyWith(void Function(GetBestMainchainBlockHashResponse) updates) => super.copyWith((message) => updates(message as GetBestMainchainBlockHashResponse)) as GetBestMainchainBlockHashResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashResponse create() => GetBestMainchainBlockHashResponse._();
  GetBestMainchainBlockHashResponse createEmptyInstance() => create();
  static $pb.PbList<GetBestMainchainBlockHashResponse> createRepeated() => $pb.PbList<GetBestMainchainBlockHashResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestMainchainBlockHashResponse>(create);
  static GetBestMainchainBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);
}

class GetBestSidechainBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBestSidechainBlockHashRequest() => create();
  GetBestSidechainBlockHashRequest._() : super();
  factory GetBestSidechainBlockHashRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBestSidechainBlockHashRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBestSidechainBlockHashRequest clone() => GetBestSidechainBlockHashRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBestSidechainBlockHashRequest copyWith(void Function(GetBestSidechainBlockHashRequest) updates) => super.copyWith((message) => updates(message as GetBestSidechainBlockHashRequest)) as GetBestSidechainBlockHashRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashRequest create() => GetBestSidechainBlockHashRequest._();
  GetBestSidechainBlockHashRequest createEmptyInstance() => create();
  static $pb.PbList<GetBestSidechainBlockHashRequest> createRepeated() => $pb.PbList<GetBestSidechainBlockHashRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestSidechainBlockHashRequest>(create);
  static GetBestSidechainBlockHashRequest? _defaultInstance;
}

class GetBestSidechainBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBestSidechainBlockHashResponse({
    $core.String? hash,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  GetBestSidechainBlockHashResponse._() : super();
  factory GetBestSidechainBlockHashResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBestSidechainBlockHashResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBestSidechainBlockHashResponse clone() => GetBestSidechainBlockHashResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBestSidechainBlockHashResponse copyWith(void Function(GetBestSidechainBlockHashResponse) updates) => super.copyWith((message) => updates(message as GetBestSidechainBlockHashResponse)) as GetBestSidechainBlockHashResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashResponse create() => GetBestSidechainBlockHashResponse._();
  GetBestSidechainBlockHashResponse createEmptyInstance() => create();
  static $pb.PbList<GetBestSidechainBlockHashResponse> createRepeated() => $pb.PbList<GetBestSidechainBlockHashResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestSidechainBlockHashResponse>(create);
  static GetBestSidechainBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);
}

class GetBmmInclusionsRequest extends $pb.GeneratedMessage {
  factory GetBmmInclusionsRequest({
    $core.String? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  GetBmmInclusionsRequest._() : super();
  factory GetBmmInclusionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmInclusionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmInclusionsRequest clone() => GetBmmInclusionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmInclusionsRequest copyWith(void Function(GetBmmInclusionsRequest) updates) => super.copyWith((message) => updates(message as GetBmmInclusionsRequest)) as GetBmmInclusionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsRequest create() => GetBmmInclusionsRequest._();
  GetBmmInclusionsRequest createEmptyInstance() => create();
  static $pb.PbList<GetBmmInclusionsRequest> createRepeated() => $pb.PbList<GetBmmInclusionsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmInclusionsRequest>(create);
  static GetBmmInclusionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
}

class GetBmmInclusionsResponse extends $pb.GeneratedMessage {
  factory GetBmmInclusionsResponse({
    $core.String? inclusions,
  }) {
    final $result = create();
    if (inclusions != null) {
      $result.inclusions = inclusions;
    }
    return $result;
  }
  GetBmmInclusionsResponse._() : super();
  factory GetBmmInclusionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmInclusionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'inclusions')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmInclusionsResponse clone() => GetBmmInclusionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmInclusionsResponse copyWith(void Function(GetBmmInclusionsResponse) updates) => super.copyWith((message) => updates(message as GetBmmInclusionsResponse)) as GetBmmInclusionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsResponse create() => GetBmmInclusionsResponse._();
  GetBmmInclusionsResponse createEmptyInstance() => create();
  static $pb.PbList<GetBmmInclusionsResponse> createRepeated() => $pb.PbList<GetBmmInclusionsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmInclusionsResponse>(create);
  static GetBmmInclusionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inclusions => $_getSZ(0);
  @$pb.TagNumber(1)
  set inclusions($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInclusions() => $_has(0);
  @$pb.TagNumber(1)
  void clearInclusions() => clearField(1);
}

class GetWalletUtxosRequest extends $pb.GeneratedMessage {
  factory GetWalletUtxosRequest() => create();
  GetWalletUtxosRequest._() : super();
  factory GetWalletUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletUtxosRequest clone() => GetWalletUtxosRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletUtxosRequest copyWith(void Function(GetWalletUtxosRequest) updates) => super.copyWith((message) => updates(message as GetWalletUtxosRequest)) as GetWalletUtxosRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosRequest create() => GetWalletUtxosRequest._();
  GetWalletUtxosRequest createEmptyInstance() => create();
  static $pb.PbList<GetWalletUtxosRequest> createRepeated() => $pb.PbList<GetWalletUtxosRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletUtxosRequest>(create);
  static GetWalletUtxosRequest? _defaultInstance;
}

class GetWalletUtxosResponse extends $pb.GeneratedMessage {
  factory GetWalletUtxosResponse({
    $core.String? utxosJson,
  }) {
    final $result = create();
    if (utxosJson != null) {
      $result.utxosJson = utxosJson;
    }
    return $result;
  }
  GetWalletUtxosResponse._() : super();
  factory GetWalletUtxosResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletUtxosResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletUtxosResponse clone() => GetWalletUtxosResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletUtxosResponse copyWith(void Function(GetWalletUtxosResponse) updates) => super.copyWith((message) => updates(message as GetWalletUtxosResponse)) as GetWalletUtxosResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosResponse create() => GetWalletUtxosResponse._();
  GetWalletUtxosResponse createEmptyInstance() => create();
  static $pb.PbList<GetWalletUtxosResponse> createRepeated() => $pb.PbList<GetWalletUtxosResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletUtxosResponse>(create);
  static GetWalletUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => clearField(1);
}

class ListUtxosRequest extends $pb.GeneratedMessage {
  factory ListUtxosRequest() => create();
  ListUtxosRequest._() : super();
  factory ListUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUtxosRequest clone() => ListUtxosRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUtxosRequest copyWith(void Function(ListUtxosRequest) updates) => super.copyWith((message) => updates(message as ListUtxosRequest)) as ListUtxosRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUtxosRequest create() => ListUtxosRequest._();
  ListUtxosRequest createEmptyInstance() => create();
  static $pb.PbList<ListUtxosRequest> createRepeated() => $pb.PbList<ListUtxosRequest>();
  @$core.pragma('dart2js:noInline')
  static ListUtxosRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosRequest>(create);
  static ListUtxosRequest? _defaultInstance;
}

class ListUtxosResponse extends $pb.GeneratedMessage {
  factory ListUtxosResponse({
    $core.String? utxosJson,
  }) {
    final $result = create();
    if (utxosJson != null) {
      $result.utxosJson = utxosJson;
    }
    return $result;
  }
  ListUtxosResponse._() : super();
  factory ListUtxosResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUtxosResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUtxosResponse clone() => ListUtxosResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUtxosResponse copyWith(void Function(ListUtxosResponse) updates) => super.copyWith((message) => updates(message as ListUtxosResponse)) as ListUtxosResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUtxosResponse create() => ListUtxosResponse._();
  ListUtxosResponse createEmptyInstance() => create();
  static $pb.PbList<ListUtxosResponse> createRepeated() => $pb.PbList<ListUtxosResponse>();
  @$core.pragma('dart2js:noInline')
  static ListUtxosResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosResponse>(create);
  static ListUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => clearField(1);
}

class RemoveFromMempoolRequest extends $pb.GeneratedMessage {
  factory RemoveFromMempoolRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  RemoveFromMempoolRequest._() : super();
  factory RemoveFromMempoolRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveFromMempoolRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveFromMempoolRequest clone() => RemoveFromMempoolRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveFromMempoolRequest copyWith(void Function(RemoveFromMempoolRequest) updates) => super.copyWith((message) => updates(message as RemoveFromMempoolRequest)) as RemoveFromMempoolRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolRequest create() => RemoveFromMempoolRequest._();
  RemoveFromMempoolRequest createEmptyInstance() => create();
  static $pb.PbList<RemoveFromMempoolRequest> createRepeated() => $pb.PbList<RemoveFromMempoolRequest>();
  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveFromMempoolRequest>(create);
  static RemoveFromMempoolRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class RemoveFromMempoolResponse extends $pb.GeneratedMessage {
  factory RemoveFromMempoolResponse() => create();
  RemoveFromMempoolResponse._() : super();
  factory RemoveFromMempoolResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveFromMempoolResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveFromMempoolResponse clone() => RemoveFromMempoolResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveFromMempoolResponse copyWith(void Function(RemoveFromMempoolResponse) updates) => super.copyWith((message) => updates(message as RemoveFromMempoolResponse)) as RemoveFromMempoolResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolResponse create() => RemoveFromMempoolResponse._();
  RemoveFromMempoolResponse createEmptyInstance() => create();
  static $pb.PbList<RemoveFromMempoolResponse> createRepeated() => $pb.PbList<RemoveFromMempoolResponse>();
  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveFromMempoolResponse>(create);
  static RemoveFromMempoolResponse? _defaultInstance;
}

class GetLatestFailedWithdrawalBundleHeightRequest extends $pb.GeneratedMessage {
  factory GetLatestFailedWithdrawalBundleHeightRequest() => create();
  GetLatestFailedWithdrawalBundleHeightRequest._() : super();
  factory GetLatestFailedWithdrawalBundleHeightRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetLatestFailedWithdrawalBundleHeightRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetLatestFailedWithdrawalBundleHeightRequest clone() => GetLatestFailedWithdrawalBundleHeightRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetLatestFailedWithdrawalBundleHeightRequest copyWith(void Function(GetLatestFailedWithdrawalBundleHeightRequest) updates) => super.copyWith((message) => updates(message as GetLatestFailedWithdrawalBundleHeightRequest)) as GetLatestFailedWithdrawalBundleHeightRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightRequest create() => GetLatestFailedWithdrawalBundleHeightRequest._();
  GetLatestFailedWithdrawalBundleHeightRequest createEmptyInstance() => create();
  static $pb.PbList<GetLatestFailedWithdrawalBundleHeightRequest> createRepeated() => $pb.PbList<GetLatestFailedWithdrawalBundleHeightRequest>();
  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetLatestFailedWithdrawalBundleHeightRequest>(create);
  static GetLatestFailedWithdrawalBundleHeightRequest? _defaultInstance;
}

class GetLatestFailedWithdrawalBundleHeightResponse extends $pb.GeneratedMessage {
  factory GetLatestFailedWithdrawalBundleHeightResponse({
    $fixnum.Int64? height,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  GetLatestFailedWithdrawalBundleHeightResponse._() : super();
  factory GetLatestFailedWithdrawalBundleHeightResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetLatestFailedWithdrawalBundleHeightResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetLatestFailedWithdrawalBundleHeightResponse clone() => GetLatestFailedWithdrawalBundleHeightResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetLatestFailedWithdrawalBundleHeightResponse copyWith(void Function(GetLatestFailedWithdrawalBundleHeightResponse) updates) => super.copyWith((message) => updates(message as GetLatestFailedWithdrawalBundleHeightResponse)) as GetLatestFailedWithdrawalBundleHeightResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightResponse create() => GetLatestFailedWithdrawalBundleHeightResponse._();
  GetLatestFailedWithdrawalBundleHeightResponse createEmptyInstance() => create();
  static $pb.PbList<GetLatestFailedWithdrawalBundleHeightResponse> createRepeated() => $pb.PbList<GetLatestFailedWithdrawalBundleHeightResponse>();
  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetLatestFailedWithdrawalBundleHeightResponse>(create);
  static GetLatestFailedWithdrawalBundleHeightResponse? _defaultInstance;

  /// 0 means no failed bundle.
  @$pb.TagNumber(1)
  $fixnum.Int64 get height => $_getI64(0);
  @$pb.TagNumber(1)
  set height($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);
}

class GenerateMnemonicRequest extends $pb.GeneratedMessage {
  factory GenerateMnemonicRequest() => create();
  GenerateMnemonicRequest._() : super();
  factory GenerateMnemonicRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateMnemonicRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateMnemonicRequest clone() => GenerateMnemonicRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateMnemonicRequest copyWith(void Function(GenerateMnemonicRequest) updates) => super.copyWith((message) => updates(message as GenerateMnemonicRequest)) as GenerateMnemonicRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicRequest create() => GenerateMnemonicRequest._();
  GenerateMnemonicRequest createEmptyInstance() => create();
  static $pb.PbList<GenerateMnemonicRequest> createRepeated() => $pb.PbList<GenerateMnemonicRequest>();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicRequest>(create);
  static GenerateMnemonicRequest? _defaultInstance;
}

class GenerateMnemonicResponse extends $pb.GeneratedMessage {
  factory GenerateMnemonicResponse({
    $core.String? mnemonic,
  }) {
    final $result = create();
    if (mnemonic != null) {
      $result.mnemonic = mnemonic;
    }
    return $result;
  }
  GenerateMnemonicResponse._() : super();
  factory GenerateMnemonicResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateMnemonicResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateMnemonicResponse clone() => GenerateMnemonicResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateMnemonicResponse copyWith(void Function(GenerateMnemonicResponse) updates) => super.copyWith((message) => updates(message as GenerateMnemonicResponse)) as GenerateMnemonicResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicResponse create() => GenerateMnemonicResponse._();
  GenerateMnemonicResponse createEmptyInstance() => create();
  static $pb.PbList<GenerateMnemonicResponse> createRepeated() => $pb.PbList<GenerateMnemonicResponse>();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicResponse>(create);
  static GenerateMnemonicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => clearField(1);
}

class SetSeedFromMnemonicRequest extends $pb.GeneratedMessage {
  factory SetSeedFromMnemonicRequest({
    $core.String? mnemonic,
  }) {
    final $result = create();
    if (mnemonic != null) {
      $result.mnemonic = mnemonic;
    }
    return $result;
  }
  SetSeedFromMnemonicRequest._() : super();
  factory SetSeedFromMnemonicRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetSeedFromMnemonicRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetSeedFromMnemonicRequest clone() => SetSeedFromMnemonicRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetSeedFromMnemonicRequest copyWith(void Function(SetSeedFromMnemonicRequest) updates) => super.copyWith((message) => updates(message as SetSeedFromMnemonicRequest)) as SetSeedFromMnemonicRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicRequest create() => SetSeedFromMnemonicRequest._();
  SetSeedFromMnemonicRequest createEmptyInstance() => create();
  static $pb.PbList<SetSeedFromMnemonicRequest> createRepeated() => $pb.PbList<SetSeedFromMnemonicRequest>();
  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetSeedFromMnemonicRequest>(create);
  static SetSeedFromMnemonicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => clearField(1);
}

class SetSeedFromMnemonicResponse extends $pb.GeneratedMessage {
  factory SetSeedFromMnemonicResponse() => create();
  SetSeedFromMnemonicResponse._() : super();
  factory SetSeedFromMnemonicResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetSeedFromMnemonicResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetSeedFromMnemonicResponse clone() => SetSeedFromMnemonicResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetSeedFromMnemonicResponse copyWith(void Function(SetSeedFromMnemonicResponse) updates) => super.copyWith((message) => updates(message as SetSeedFromMnemonicResponse)) as SetSeedFromMnemonicResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicResponse create() => SetSeedFromMnemonicResponse._();
  SetSeedFromMnemonicResponse createEmptyInstance() => create();
  static $pb.PbList<SetSeedFromMnemonicResponse> createRepeated() => $pb.PbList<SetSeedFromMnemonicResponse>();
  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetSeedFromMnemonicResponse>(create);
  static SetSeedFromMnemonicResponse? _defaultInstance;
}

class CallRawRequest extends $pb.GeneratedMessage {
  factory CallRawRequest({
    $core.String? method,
    $core.String? paramsJson,
  }) {
    final $result = create();
    if (method != null) {
      $result.method = method;
    }
    if (paramsJson != null) {
      $result.paramsJson = paramsJson;
    }
    return $result;
  }
  CallRawRequest._() : super();
  factory CallRawRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CallRawRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..aOS(2, _omitFieldNames ? '' : 'paramsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CallRawRequest clone() => CallRawRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CallRawRequest copyWith(void Function(CallRawRequest) updates) => super.copyWith((message) => updates(message as CallRawRequest)) as CallRawRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallRawRequest create() => CallRawRequest._();
  CallRawRequest createEmptyInstance() => create();
  static $pb.PbList<CallRawRequest> createRepeated() => $pb.PbList<CallRawRequest>();
  @$core.pragma('dart2js:noInline')
  static CallRawRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallRawRequest>(create);
  static CallRawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get paramsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set paramsJson($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasParamsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearParamsJson() => clearField(2);
}

class CallRawResponse extends $pb.GeneratedMessage {
  factory CallRawResponse({
    $core.String? resultJson,
  }) {
    final $result = create();
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    return $result;
  }
  CallRawResponse._() : super();
  factory CallRawResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CallRawResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CallRawResponse clone() => CallRawResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CallRawResponse copyWith(void Function(CallRawResponse) updates) => super.copyWith((message) => updates(message as CallRawResponse)) as CallRawResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallRawResponse create() => CallRawResponse._();
  CallRawResponse createEmptyInstance() => create();
  static $pb.PbList<CallRawResponse> createRepeated() => $pb.PbList<CallRawResponse>();
  @$core.pragma('dart2js:noInline')
  static CallRawResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallRawResponse>(create);
  static CallRawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class GetBitAssetDataRequest extends $pb.GeneratedMessage {
  factory GetBitAssetDataRequest({
    $core.String? assetId,
  }) {
    final $result = create();
    if (assetId != null) {
      $result.assetId = assetId;
    }
    return $result;
  }
  GetBitAssetDataRequest._() : super();
  factory GetBitAssetDataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBitAssetDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitAssetDataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'assetId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBitAssetDataRequest clone() => GetBitAssetDataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBitAssetDataRequest copyWith(void Function(GetBitAssetDataRequest) updates) => super.copyWith((message) => updates(message as GetBitAssetDataRequest)) as GetBitAssetDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataRequest create() => GetBitAssetDataRequest._();
  GetBitAssetDataRequest createEmptyInstance() => create();
  static $pb.PbList<GetBitAssetDataRequest> createRepeated() => $pb.PbList<GetBitAssetDataRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBitAssetDataRequest>(create);
  static GetBitAssetDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => clearField(1);
}

class GetBitAssetDataResponse extends $pb.GeneratedMessage {
  factory GetBitAssetDataResponse({
    $core.String? dataJson,
  }) {
    final $result = create();
    if (dataJson != null) {
      $result.dataJson = dataJson;
    }
    return $result;
  }
  GetBitAssetDataResponse._() : super();
  factory GetBitAssetDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBitAssetDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitAssetDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBitAssetDataResponse clone() => GetBitAssetDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBitAssetDataResponse copyWith(void Function(GetBitAssetDataResponse) updates) => super.copyWith((message) => updates(message as GetBitAssetDataResponse)) as GetBitAssetDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataResponse create() => GetBitAssetDataResponse._();
  GetBitAssetDataResponse createEmptyInstance() => create();
  static $pb.PbList<GetBitAssetDataResponse> createRepeated() => $pb.PbList<GetBitAssetDataResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBitAssetDataResponse>(create);
  static GetBitAssetDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDataJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataJson() => clearField(1);
}

class ListBitAssetsRequest extends $pb.GeneratedMessage {
  factory ListBitAssetsRequest() => create();
  ListBitAssetsRequest._() : super();
  factory ListBitAssetsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBitAssetsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitAssetsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBitAssetsRequest clone() => ListBitAssetsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBitAssetsRequest copyWith(void Function(ListBitAssetsRequest) updates) => super.copyWith((message) => updates(message as ListBitAssetsRequest)) as ListBitAssetsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBitAssetsRequest create() => ListBitAssetsRequest._();
  ListBitAssetsRequest createEmptyInstance() => create();
  static $pb.PbList<ListBitAssetsRequest> createRepeated() => $pb.PbList<ListBitAssetsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBitAssetsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBitAssetsRequest>(create);
  static ListBitAssetsRequest? _defaultInstance;
}

class ListBitAssetsResponse extends $pb.GeneratedMessage {
  factory ListBitAssetsResponse({
    $core.String? bitassetsJson,
  }) {
    final $result = create();
    if (bitassetsJson != null) {
      $result.bitassetsJson = bitassetsJson;
    }
    return $result;
  }
  ListBitAssetsResponse._() : super();
  factory ListBitAssetsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBitAssetsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitAssetsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'bitassetsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBitAssetsResponse clone() => ListBitAssetsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBitAssetsResponse copyWith(void Function(ListBitAssetsResponse) updates) => super.copyWith((message) => updates(message as ListBitAssetsResponse)) as ListBitAssetsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBitAssetsResponse create() => ListBitAssetsResponse._();
  ListBitAssetsResponse createEmptyInstance() => create();
  static $pb.PbList<ListBitAssetsResponse> createRepeated() => $pb.PbList<ListBitAssetsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBitAssetsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBitAssetsResponse>(create);
  static ListBitAssetsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bitassetsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bitassetsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBitassetsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitassetsJson() => clearField(1);
}

class RegisterBitAssetRequest extends $pb.GeneratedMessage {
  factory RegisterBitAssetRequest({
    $core.String? plaintextName,
    $fixnum.Int64? initialSupply,
    $core.String? dataJson,
  }) {
    final $result = create();
    if (plaintextName != null) {
      $result.plaintextName = plaintextName;
    }
    if (initialSupply != null) {
      $result.initialSupply = initialSupply;
    }
    if (dataJson != null) {
      $result.dataJson = dataJson;
    }
    return $result;
  }
  RegisterBitAssetRequest._() : super();
  factory RegisterBitAssetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterBitAssetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitAssetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plaintextName')
    ..aInt64(2, _omitFieldNames ? '' : 'initialSupply')
    ..aOS(3, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterBitAssetRequest clone() => RegisterBitAssetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterBitAssetRequest copyWith(void Function(RegisterBitAssetRequest) updates) => super.copyWith((message) => updates(message as RegisterBitAssetRequest)) as RegisterBitAssetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetRequest create() => RegisterBitAssetRequest._();
  RegisterBitAssetRequest createEmptyInstance() => create();
  static $pb.PbList<RegisterBitAssetRequest> createRepeated() => $pb.PbList<RegisterBitAssetRequest>();
  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterBitAssetRequest>(create);
  static RegisterBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plaintextName => $_getSZ(0);
  @$pb.TagNumber(1)
  set plaintextName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlaintextName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlaintextName() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get initialSupply => $_getI64(1);
  @$pb.TagNumber(2)
  set initialSupply($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInitialSupply() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitialSupply() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get dataJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set dataJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDataJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataJson() => clearField(3);
}

class RegisterBitAssetResponse extends $pb.GeneratedMessage {
  factory RegisterBitAssetResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  RegisterBitAssetResponse._() : super();
  factory RegisterBitAssetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterBitAssetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitAssetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterBitAssetResponse clone() => RegisterBitAssetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterBitAssetResponse copyWith(void Function(RegisterBitAssetResponse) updates) => super.copyWith((message) => updates(message as RegisterBitAssetResponse)) as RegisterBitAssetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetResponse create() => RegisterBitAssetResponse._();
  RegisterBitAssetResponse createEmptyInstance() => create();
  static $pb.PbList<RegisterBitAssetResponse> createRepeated() => $pb.PbList<RegisterBitAssetResponse>();
  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterBitAssetResponse>(create);
  static RegisterBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ReserveBitAssetRequest extends $pb.GeneratedMessage {
  factory ReserveBitAssetRequest({
    $core.String? name,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  ReserveBitAssetRequest._() : super();
  factory ReserveBitAssetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReserveBitAssetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitAssetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReserveBitAssetRequest clone() => ReserveBitAssetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReserveBitAssetRequest copyWith(void Function(ReserveBitAssetRequest) updates) => super.copyWith((message) => updates(message as ReserveBitAssetRequest)) as ReserveBitAssetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetRequest create() => ReserveBitAssetRequest._();
  ReserveBitAssetRequest createEmptyInstance() => create();
  static $pb.PbList<ReserveBitAssetRequest> createRepeated() => $pb.PbList<ReserveBitAssetRequest>();
  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveBitAssetRequest>(create);
  static ReserveBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class ReserveBitAssetResponse extends $pb.GeneratedMessage {
  factory ReserveBitAssetResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  ReserveBitAssetResponse._() : super();
  factory ReserveBitAssetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReserveBitAssetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitAssetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReserveBitAssetResponse clone() => ReserveBitAssetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReserveBitAssetResponse copyWith(void Function(ReserveBitAssetResponse) updates) => super.copyWith((message) => updates(message as ReserveBitAssetResponse)) as ReserveBitAssetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetResponse create() => ReserveBitAssetResponse._();
  ReserveBitAssetResponse createEmptyInstance() => create();
  static $pb.PbList<ReserveBitAssetResponse> createRepeated() => $pb.PbList<ReserveBitAssetResponse>();
  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveBitAssetResponse>(create);
  static ReserveBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class TransferBitAssetRequest extends $pb.GeneratedMessage {
  factory TransferBitAssetRequest({
    $core.String? assetId,
    $core.String? dest,
    $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (assetId != null) {
      $result.assetId = assetId;
    }
    if (dest != null) {
      $result.dest = dest;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  TransferBitAssetRequest._() : super();
  factory TransferBitAssetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferBitAssetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferBitAssetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'assetId')
    ..aOS(2, _omitFieldNames ? '' : 'dest')
    ..aInt64(3, _omitFieldNames ? '' : 'amount')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferBitAssetRequest clone() => TransferBitAssetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferBitAssetRequest copyWith(void Function(TransferBitAssetRequest) updates) => super.copyWith((message) => updates(message as TransferBitAssetRequest)) as TransferBitAssetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferBitAssetRequest create() => TransferBitAssetRequest._();
  TransferBitAssetRequest createEmptyInstance() => create();
  static $pb.PbList<TransferBitAssetRequest> createRepeated() => $pb.PbList<TransferBitAssetRequest>();
  @$core.pragma('dart2js:noInline')
  static TransferBitAssetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferBitAssetRequest>(create);
  static TransferBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get dest => $_getSZ(1);
  @$pb.TagNumber(2)
  set dest($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDest() => $_has(1);
  @$pb.TagNumber(2)
  void clearDest() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);
}

class TransferBitAssetResponse extends $pb.GeneratedMessage {
  factory TransferBitAssetResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TransferBitAssetResponse._() : super();
  factory TransferBitAssetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferBitAssetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferBitAssetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferBitAssetResponse clone() => TransferBitAssetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferBitAssetResponse copyWith(void Function(TransferBitAssetResponse) updates) => super.copyWith((message) => updates(message as TransferBitAssetResponse)) as TransferBitAssetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferBitAssetResponse create() => TransferBitAssetResponse._();
  TransferBitAssetResponse createEmptyInstance() => create();
  static $pb.PbList<TransferBitAssetResponse> createRepeated() => $pb.PbList<TransferBitAssetResponse>();
  @$core.pragma('dart2js:noInline')
  static TransferBitAssetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferBitAssetResponse>(create);
  static TransferBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetNewEncryptionKeyRequest extends $pb.GeneratedMessage {
  factory GetNewEncryptionKeyRequest() => create();
  GetNewEncryptionKeyRequest._() : super();
  factory GetNewEncryptionKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewEncryptionKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewEncryptionKeyRequest clone() => GetNewEncryptionKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewEncryptionKeyRequest copyWith(void Function(GetNewEncryptionKeyRequest) updates) => super.copyWith((message) => updates(message as GetNewEncryptionKeyRequest)) as GetNewEncryptionKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyRequest create() => GetNewEncryptionKeyRequest._();
  GetNewEncryptionKeyRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewEncryptionKeyRequest> createRepeated() => $pb.PbList<GetNewEncryptionKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewEncryptionKeyRequest>(create);
  static GetNewEncryptionKeyRequest? _defaultInstance;
}

class GetNewEncryptionKeyResponse extends $pb.GeneratedMessage {
  factory GetNewEncryptionKeyResponse({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  GetNewEncryptionKeyResponse._() : super();
  factory GetNewEncryptionKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewEncryptionKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewEncryptionKeyResponse clone() => GetNewEncryptionKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewEncryptionKeyResponse copyWith(void Function(GetNewEncryptionKeyResponse) updates) => super.copyWith((message) => updates(message as GetNewEncryptionKeyResponse)) as GetNewEncryptionKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyResponse create() => GetNewEncryptionKeyResponse._();
  GetNewEncryptionKeyResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewEncryptionKeyResponse> createRepeated() => $pb.PbList<GetNewEncryptionKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewEncryptionKeyResponse>(create);
  static GetNewEncryptionKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class GetNewVerifyingKeyRequest extends $pb.GeneratedMessage {
  factory GetNewVerifyingKeyRequest() => create();
  GetNewVerifyingKeyRequest._() : super();
  factory GetNewVerifyingKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewVerifyingKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewVerifyingKeyRequest clone() => GetNewVerifyingKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewVerifyingKeyRequest copyWith(void Function(GetNewVerifyingKeyRequest) updates) => super.copyWith((message) => updates(message as GetNewVerifyingKeyRequest)) as GetNewVerifyingKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyRequest create() => GetNewVerifyingKeyRequest._();
  GetNewVerifyingKeyRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewVerifyingKeyRequest> createRepeated() => $pb.PbList<GetNewVerifyingKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewVerifyingKeyRequest>(create);
  static GetNewVerifyingKeyRequest? _defaultInstance;
}

class GetNewVerifyingKeyResponse extends $pb.GeneratedMessage {
  factory GetNewVerifyingKeyResponse({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  GetNewVerifyingKeyResponse._() : super();
  factory GetNewVerifyingKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewVerifyingKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewVerifyingKeyResponse clone() => GetNewVerifyingKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewVerifyingKeyResponse copyWith(void Function(GetNewVerifyingKeyResponse) updates) => super.copyWith((message) => updates(message as GetNewVerifyingKeyResponse)) as GetNewVerifyingKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyResponse create() => GetNewVerifyingKeyResponse._();
  GetNewVerifyingKeyResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewVerifyingKeyResponse> createRepeated() => $pb.PbList<GetNewVerifyingKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewVerifyingKeyResponse>(create);
  static GetNewVerifyingKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class DecryptMsgRequest extends $pb.GeneratedMessage {
  factory DecryptMsgRequest({
    $core.String? ciphertext,
    $core.String? encryptionPubkey,
  }) {
    final $result = create();
    if (ciphertext != null) {
      $result.ciphertext = ciphertext;
    }
    if (encryptionPubkey != null) {
      $result.encryptionPubkey = encryptionPubkey;
    }
    return $result;
  }
  DecryptMsgRequest._() : super();
  factory DecryptMsgRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecryptMsgRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ciphertext')
    ..aOS(2, _omitFieldNames ? '' : 'encryptionPubkey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecryptMsgRequest clone() => DecryptMsgRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecryptMsgRequest copyWith(void Function(DecryptMsgRequest) updates) => super.copyWith((message) => updates(message as DecryptMsgRequest)) as DecryptMsgRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecryptMsgRequest create() => DecryptMsgRequest._();
  DecryptMsgRequest createEmptyInstance() => create();
  static $pb.PbList<DecryptMsgRequest> createRepeated() => $pb.PbList<DecryptMsgRequest>();
  @$core.pragma('dart2js:noInline')
  static DecryptMsgRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecryptMsgRequest>(create);
  static DecryptMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ciphertext => $_getSZ(0);
  @$pb.TagNumber(1)
  set ciphertext($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCiphertext() => $_has(0);
  @$pb.TagNumber(1)
  void clearCiphertext() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptionPubkey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptionPubkey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptionPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionPubkey() => clearField(2);
}

class DecryptMsgResponse extends $pb.GeneratedMessage {
  factory DecryptMsgResponse({
    $core.String? plaintext,
  }) {
    final $result = create();
    if (plaintext != null) {
      $result.plaintext = plaintext;
    }
    return $result;
  }
  DecryptMsgResponse._() : super();
  factory DecryptMsgResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecryptMsgResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plaintext')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecryptMsgResponse clone() => DecryptMsgResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecryptMsgResponse copyWith(void Function(DecryptMsgResponse) updates) => super.copyWith((message) => updates(message as DecryptMsgResponse)) as DecryptMsgResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecryptMsgResponse create() => DecryptMsgResponse._();
  DecryptMsgResponse createEmptyInstance() => create();
  static $pb.PbList<DecryptMsgResponse> createRepeated() => $pb.PbList<DecryptMsgResponse>();
  @$core.pragma('dart2js:noInline')
  static DecryptMsgResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecryptMsgResponse>(create);
  static DecryptMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plaintext => $_getSZ(0);
  @$pb.TagNumber(1)
  set plaintext($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlaintext() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlaintext() => clearField(1);
}

class EncryptMsgRequest extends $pb.GeneratedMessage {
  factory EncryptMsgRequest({
    $core.String? msg,
    $core.String? encryptionPubkey,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    if (encryptionPubkey != null) {
      $result.encryptionPubkey = encryptionPubkey;
    }
    return $result;
  }
  EncryptMsgRequest._() : super();
  factory EncryptMsgRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncryptMsgRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'encryptionPubkey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncryptMsgRequest clone() => EncryptMsgRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncryptMsgRequest copyWith(void Function(EncryptMsgRequest) updates) => super.copyWith((message) => updates(message as EncryptMsgRequest)) as EncryptMsgRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptMsgRequest create() => EncryptMsgRequest._();
  EncryptMsgRequest createEmptyInstance() => create();
  static $pb.PbList<EncryptMsgRequest> createRepeated() => $pb.PbList<EncryptMsgRequest>();
  @$core.pragma('dart2js:noInline')
  static EncryptMsgRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptMsgRequest>(create);
  static EncryptMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptionPubkey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptionPubkey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptionPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionPubkey() => clearField(2);
}

class EncryptMsgResponse extends $pb.GeneratedMessage {
  factory EncryptMsgResponse({
    $core.String? ciphertext,
  }) {
    final $result = create();
    if (ciphertext != null) {
      $result.ciphertext = ciphertext;
    }
    return $result;
  }
  EncryptMsgResponse._() : super();
  factory EncryptMsgResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncryptMsgResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ciphertext')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncryptMsgResponse clone() => EncryptMsgResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncryptMsgResponse copyWith(void Function(EncryptMsgResponse) updates) => super.copyWith((message) => updates(message as EncryptMsgResponse)) as EncryptMsgResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptMsgResponse create() => EncryptMsgResponse._();
  EncryptMsgResponse createEmptyInstance() => create();
  static $pb.PbList<EncryptMsgResponse> createRepeated() => $pb.PbList<EncryptMsgResponse>();
  @$core.pragma('dart2js:noInline')
  static EncryptMsgResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptMsgResponse>(create);
  static EncryptMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ciphertext => $_getSZ(0);
  @$pb.TagNumber(1)
  set ciphertext($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCiphertext() => $_has(0);
  @$pb.TagNumber(1)
  void clearCiphertext() => clearField(1);
}

class SignArbitraryMsgRequest extends $pb.GeneratedMessage {
  factory SignArbitraryMsgRequest({
    $core.String? msg,
    $core.String? verifyingKey,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    if (verifyingKey != null) {
      $result.verifyingKey = verifyingKey;
    }
    return $result;
  }
  SignArbitraryMsgRequest._() : super();
  factory SignArbitraryMsgRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignArbitraryMsgRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'verifyingKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgRequest clone() => SignArbitraryMsgRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgRequest copyWith(void Function(SignArbitraryMsgRequest) updates) => super.copyWith((message) => updates(message as SignArbitraryMsgRequest)) as SignArbitraryMsgRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgRequest create() => SignArbitraryMsgRequest._();
  SignArbitraryMsgRequest createEmptyInstance() => create();
  static $pb.PbList<SignArbitraryMsgRequest> createRepeated() => $pb.PbList<SignArbitraryMsgRequest>();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgRequest>(create);
  static SignArbitraryMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get verifyingKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set verifyingKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerifyingKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerifyingKey() => clearField(2);
}

class SignArbitraryMsgResponse extends $pb.GeneratedMessage {
  factory SignArbitraryMsgResponse({
    $core.String? signature,
  }) {
    final $result = create();
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  SignArbitraryMsgResponse._() : super();
  factory SignArbitraryMsgResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignArbitraryMsgResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgResponse clone() => SignArbitraryMsgResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgResponse copyWith(void Function(SignArbitraryMsgResponse) updates) => super.copyWith((message) => updates(message as SignArbitraryMsgResponse)) as SignArbitraryMsgResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgResponse create() => SignArbitraryMsgResponse._();
  SignArbitraryMsgResponse createEmptyInstance() => create();
  static $pb.PbList<SignArbitraryMsgResponse> createRepeated() => $pb.PbList<SignArbitraryMsgResponse>();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgResponse>(create);
  static SignArbitraryMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => clearField(1);
}

class SignArbitraryMsgAsAddrRequest extends $pb.GeneratedMessage {
  factory SignArbitraryMsgAsAddrRequest({
    $core.String? msg,
    $core.String? address,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  SignArbitraryMsgAsAddrRequest._() : super();
  factory SignArbitraryMsgAsAddrRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignArbitraryMsgAsAddrRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgAsAddrRequest clone() => SignArbitraryMsgAsAddrRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgAsAddrRequest copyWith(void Function(SignArbitraryMsgAsAddrRequest) updates) => super.copyWith((message) => updates(message as SignArbitraryMsgAsAddrRequest)) as SignArbitraryMsgAsAddrRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrRequest create() => SignArbitraryMsgAsAddrRequest._();
  SignArbitraryMsgAsAddrRequest createEmptyInstance() => create();
  static $pb.PbList<SignArbitraryMsgAsAddrRequest> createRepeated() => $pb.PbList<SignArbitraryMsgAsAddrRequest>();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgAsAddrRequest>(create);
  static SignArbitraryMsgAsAddrRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);
}

class SignArbitraryMsgAsAddrResponse extends $pb.GeneratedMessage {
  factory SignArbitraryMsgAsAddrResponse({
    $core.String? verifyingKey,
    $core.String? signature,
  }) {
    final $result = create();
    if (verifyingKey != null) {
      $result.verifyingKey = verifyingKey;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  SignArbitraryMsgAsAddrResponse._() : super();
  factory SignArbitraryMsgAsAddrResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignArbitraryMsgAsAddrResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'verifyingKey')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgAsAddrResponse clone() => SignArbitraryMsgAsAddrResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignArbitraryMsgAsAddrResponse copyWith(void Function(SignArbitraryMsgAsAddrResponse) updates) => super.copyWith((message) => updates(message as SignArbitraryMsgAsAddrResponse)) as SignArbitraryMsgAsAddrResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrResponse create() => SignArbitraryMsgAsAddrResponse._();
  SignArbitraryMsgAsAddrResponse createEmptyInstance() => create();
  static $pb.PbList<SignArbitraryMsgAsAddrResponse> createRepeated() => $pb.PbList<SignArbitraryMsgAsAddrResponse>();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgAsAddrResponse>(create);
  static SignArbitraryMsgAsAddrResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get verifyingKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set verifyingKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVerifyingKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerifyingKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get signature => $_getSZ(1);
  @$pb.TagNumber(2)
  set signature($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);
}

class VerifySignatureRequest extends $pb.GeneratedMessage {
  factory VerifySignatureRequest({
    $core.String? msg,
    $core.String? signature,
    $core.String? verifyingKey,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    if (verifyingKey != null) {
      $result.verifyingKey = verifyingKey;
    }
    return $result;
  }
  VerifySignatureRequest._() : super();
  factory VerifySignatureRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifySignatureRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..aOS(3, _omitFieldNames ? '' : 'verifyingKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifySignatureRequest clone() => VerifySignatureRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifySignatureRequest copyWith(void Function(VerifySignatureRequest) updates) => super.copyWith((message) => updates(message as VerifySignatureRequest)) as VerifySignatureRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifySignatureRequest create() => VerifySignatureRequest._();
  VerifySignatureRequest createEmptyInstance() => create();
  static $pb.PbList<VerifySignatureRequest> createRepeated() => $pb.PbList<VerifySignatureRequest>();
  @$core.pragma('dart2js:noInline')
  static VerifySignatureRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifySignatureRequest>(create);
  static VerifySignatureRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get signature => $_getSZ(1);
  @$pb.TagNumber(2)
  set signature($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get verifyingKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set verifyingKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVerifyingKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerifyingKey() => clearField(3);
}

class VerifySignatureResponse extends $pb.GeneratedMessage {
  factory VerifySignatureResponse({
    $core.bool? valid,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    return $result;
  }
  VerifySignatureResponse._() : super();
  factory VerifySignatureResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifySignatureResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifySignatureResponse clone() => VerifySignatureResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifySignatureResponse copyWith(void Function(VerifySignatureResponse) updates) => super.copyWith((message) => updates(message as VerifySignatureResponse)) as VerifySignatureResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifySignatureResponse create() => VerifySignatureResponse._();
  VerifySignatureResponse createEmptyInstance() => create();
  static $pb.PbList<VerifySignatureResponse> createRepeated() => $pb.PbList<VerifySignatureResponse>();
  @$core.pragma('dart2js:noInline')
  static VerifySignatureResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifySignatureResponse>(create);
  static VerifySignatureResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);
}

class GetWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetWalletAddressesRequest() => create();
  GetWalletAddressesRequest._() : super();
  factory GetWalletAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletAddressesRequest clone() => GetWalletAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletAddressesRequest copyWith(void Function(GetWalletAddressesRequest) updates) => super.copyWith((message) => updates(message as GetWalletAddressesRequest)) as GetWalletAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesRequest create() => GetWalletAddressesRequest._();
  GetWalletAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<GetWalletAddressesRequest> createRepeated() => $pb.PbList<GetWalletAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletAddressesRequest>(create);
  static GetWalletAddressesRequest? _defaultInstance;
}

class GetWalletAddressesResponse extends $pb.GeneratedMessage {
  factory GetWalletAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  GetWalletAddressesResponse._() : super();
  factory GetWalletAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletAddressesResponse clone() => GetWalletAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletAddressesResponse copyWith(void Function(GetWalletAddressesResponse) updates) => super.copyWith((message) => updates(message as GetWalletAddressesResponse)) as GetWalletAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesResponse create() => GetWalletAddressesResponse._();
  GetWalletAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<GetWalletAddressesResponse> createRepeated() => $pb.PbList<GetWalletAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletAddressesResponse>(create);
  static GetWalletAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
}

class MyUnconfirmedUtxosRequest extends $pb.GeneratedMessage {
  factory MyUnconfirmedUtxosRequest() => create();
  MyUnconfirmedUtxosRequest._() : super();
  factory MyUnconfirmedUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUnconfirmedUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyUnconfirmedUtxosRequest clone() => MyUnconfirmedUtxosRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyUnconfirmedUtxosRequest copyWith(void Function(MyUnconfirmedUtxosRequest) updates) => super.copyWith((message) => updates(message as MyUnconfirmedUtxosRequest)) as MyUnconfirmedUtxosRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosRequest create() => MyUnconfirmedUtxosRequest._();
  MyUnconfirmedUtxosRequest createEmptyInstance() => create();
  static $pb.PbList<MyUnconfirmedUtxosRequest> createRepeated() => $pb.PbList<MyUnconfirmedUtxosRequest>();
  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUnconfirmedUtxosRequest>(create);
  static MyUnconfirmedUtxosRequest? _defaultInstance;
}

class MyUnconfirmedUtxosResponse extends $pb.GeneratedMessage {
  factory MyUnconfirmedUtxosResponse({
    $core.String? utxosJson,
  }) {
    final $result = create();
    if (utxosJson != null) {
      $result.utxosJson = utxosJson;
    }
    return $result;
  }
  MyUnconfirmedUtxosResponse._() : super();
  factory MyUnconfirmedUtxosResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUnconfirmedUtxosResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyUnconfirmedUtxosResponse clone() => MyUnconfirmedUtxosResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyUnconfirmedUtxosResponse copyWith(void Function(MyUnconfirmedUtxosResponse) updates) => super.copyWith((message) => updates(message as MyUnconfirmedUtxosResponse)) as MyUnconfirmedUtxosResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosResponse create() => MyUnconfirmedUtxosResponse._();
  MyUnconfirmedUtxosResponse createEmptyInstance() => create();
  static $pb.PbList<MyUnconfirmedUtxosResponse> createRepeated() => $pb.PbList<MyUnconfirmedUtxosResponse>();
  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUnconfirmedUtxosResponse>(create);
  static MyUnconfirmedUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => clearField(1);
}

class OpenapiSchemaRequest extends $pb.GeneratedMessage {
  factory OpenapiSchemaRequest() => create();
  OpenapiSchemaRequest._() : super();
  factory OpenapiSchemaRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenapiSchemaRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpenapiSchemaRequest clone() => OpenapiSchemaRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpenapiSchemaRequest copyWith(void Function(OpenapiSchemaRequest) updates) => super.copyWith((message) => updates(message as OpenapiSchemaRequest)) as OpenapiSchemaRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaRequest create() => OpenapiSchemaRequest._();
  OpenapiSchemaRequest createEmptyInstance() => create();
  static $pb.PbList<OpenapiSchemaRequest> createRepeated() => $pb.PbList<OpenapiSchemaRequest>();
  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenapiSchemaRequest>(create);
  static OpenapiSchemaRequest? _defaultInstance;
}

class OpenapiSchemaResponse extends $pb.GeneratedMessage {
  factory OpenapiSchemaResponse({
    $core.String? schemaJson,
  }) {
    final $result = create();
    if (schemaJson != null) {
      $result.schemaJson = schemaJson;
    }
    return $result;
  }
  OpenapiSchemaResponse._() : super();
  factory OpenapiSchemaResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenapiSchemaResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'schemaJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpenapiSchemaResponse clone() => OpenapiSchemaResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpenapiSchemaResponse copyWith(void Function(OpenapiSchemaResponse) updates) => super.copyWith((message) => updates(message as OpenapiSchemaResponse)) as OpenapiSchemaResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaResponse create() => OpenapiSchemaResponse._();
  OpenapiSchemaResponse createEmptyInstance() => create();
  static $pb.PbList<OpenapiSchemaResponse> createRepeated() => $pb.PbList<OpenapiSchemaResponse>();
  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenapiSchemaResponse>(create);
  static OpenapiSchemaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get schemaJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set schemaJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSchemaJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaJson() => clearField(1);
}

class AmmBurnRequest extends $pb.GeneratedMessage {
  factory AmmBurnRequest({
    $core.String? asset0,
    $core.String? asset1,
    $fixnum.Int64? lpTokenAmount,
  }) {
    final $result = create();
    if (asset0 != null) {
      $result.asset0 = asset0;
    }
    if (asset1 != null) {
      $result.asset1 = asset1;
    }
    if (lpTokenAmount != null) {
      $result.lpTokenAmount = lpTokenAmount;
    }
    return $result;
  }
  AmmBurnRequest._() : super();
  factory AmmBurnRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmBurnRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmBurnRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..aInt64(3, _omitFieldNames ? '' : 'lpTokenAmount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmBurnRequest clone() => AmmBurnRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmBurnRequest copyWith(void Function(AmmBurnRequest) updates) => super.copyWith((message) => updates(message as AmmBurnRequest)) as AmmBurnRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmBurnRequest create() => AmmBurnRequest._();
  AmmBurnRequest createEmptyInstance() => create();
  static $pb.PbList<AmmBurnRequest> createRepeated() => $pb.PbList<AmmBurnRequest>();
  @$core.pragma('dart2js:noInline')
  static AmmBurnRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmBurnRequest>(create);
  static AmmBurnRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lpTokenAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set lpTokenAmount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLpTokenAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearLpTokenAmount() => clearField(3);
}

class AmmBurnResponse extends $pb.GeneratedMessage {
  factory AmmBurnResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  AmmBurnResponse._() : super();
  factory AmmBurnResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmBurnResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmBurnResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmBurnResponse clone() => AmmBurnResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmBurnResponse copyWith(void Function(AmmBurnResponse) updates) => super.copyWith((message) => updates(message as AmmBurnResponse)) as AmmBurnResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmBurnResponse create() => AmmBurnResponse._();
  AmmBurnResponse createEmptyInstance() => create();
  static $pb.PbList<AmmBurnResponse> createRepeated() => $pb.PbList<AmmBurnResponse>();
  @$core.pragma('dart2js:noInline')
  static AmmBurnResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmBurnResponse>(create);
  static AmmBurnResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class AmmMintRequest extends $pb.GeneratedMessage {
  factory AmmMintRequest({
    $core.String? asset0,
    $core.String? asset1,
    $fixnum.Int64? amount0,
    $fixnum.Int64? amount1,
  }) {
    final $result = create();
    if (asset0 != null) {
      $result.asset0 = asset0;
    }
    if (asset1 != null) {
      $result.asset1 = asset1;
    }
    if (amount0 != null) {
      $result.amount0 = amount0;
    }
    if (amount1 != null) {
      $result.amount1 = amount1;
    }
    return $result;
  }
  AmmMintRequest._() : super();
  factory AmmMintRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmMintRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmMintRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..aInt64(3, _omitFieldNames ? '' : 'amount0')
    ..aInt64(4, _omitFieldNames ? '' : 'amount1')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmMintRequest clone() => AmmMintRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmMintRequest copyWith(void Function(AmmMintRequest) updates) => super.copyWith((message) => updates(message as AmmMintRequest)) as AmmMintRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmMintRequest create() => AmmMintRequest._();
  AmmMintRequest createEmptyInstance() => create();
  static $pb.PbList<AmmMintRequest> createRepeated() => $pb.PbList<AmmMintRequest>();
  @$core.pragma('dart2js:noInline')
  static AmmMintRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmMintRequest>(create);
  static AmmMintRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount0 => $_getI64(2);
  @$pb.TagNumber(3)
  set amount0($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount0() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount0() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount1 => $_getI64(3);
  @$pb.TagNumber(4)
  set amount1($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount1() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount1() => clearField(4);
}

class AmmMintResponse extends $pb.GeneratedMessage {
  factory AmmMintResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  AmmMintResponse._() : super();
  factory AmmMintResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmMintResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmMintResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmMintResponse clone() => AmmMintResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmMintResponse copyWith(void Function(AmmMintResponse) updates) => super.copyWith((message) => updates(message as AmmMintResponse)) as AmmMintResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmMintResponse create() => AmmMintResponse._();
  AmmMintResponse createEmptyInstance() => create();
  static $pb.PbList<AmmMintResponse> createRepeated() => $pb.PbList<AmmMintResponse>();
  @$core.pragma('dart2js:noInline')
  static AmmMintResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmMintResponse>(create);
  static AmmMintResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class AmmSwapRequest extends $pb.GeneratedMessage {
  factory AmmSwapRequest({
    $core.String? assetSpend,
    $core.String? assetReceive,
    $fixnum.Int64? amountSpend,
  }) {
    final $result = create();
    if (assetSpend != null) {
      $result.assetSpend = assetSpend;
    }
    if (assetReceive != null) {
      $result.assetReceive = assetReceive;
    }
    if (amountSpend != null) {
      $result.amountSpend = amountSpend;
    }
    return $result;
  }
  AmmSwapRequest._() : super();
  factory AmmSwapRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmSwapRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmSwapRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'assetSpend')
    ..aOS(2, _omitFieldNames ? '' : 'assetReceive')
    ..aInt64(3, _omitFieldNames ? '' : 'amountSpend')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmSwapRequest clone() => AmmSwapRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmSwapRequest copyWith(void Function(AmmSwapRequest) updates) => super.copyWith((message) => updates(message as AmmSwapRequest)) as AmmSwapRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmSwapRequest create() => AmmSwapRequest._();
  AmmSwapRequest createEmptyInstance() => create();
  static $pb.PbList<AmmSwapRequest> createRepeated() => $pb.PbList<AmmSwapRequest>();
  @$core.pragma('dart2js:noInline')
  static AmmSwapRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmSwapRequest>(create);
  static AmmSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetSpend => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetSpend($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAssetSpend() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetSpend() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get assetReceive => $_getSZ(1);
  @$pb.TagNumber(2)
  set assetReceive($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAssetReceive() => $_has(1);
  @$pb.TagNumber(2)
  void clearAssetReceive() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSpend => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSpend($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmountSpend() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSpend() => clearField(3);
}

class AmmSwapResponse extends $pb.GeneratedMessage {
  factory AmmSwapResponse({
    $fixnum.Int64? amountReceive,
  }) {
    final $result = create();
    if (amountReceive != null) {
      $result.amountReceive = amountReceive;
    }
    return $result;
  }
  AmmSwapResponse._() : super();
  factory AmmSwapResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AmmSwapResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmSwapResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'amountReceive')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AmmSwapResponse clone() => AmmSwapResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AmmSwapResponse copyWith(void Function(AmmSwapResponse) updates) => super.copyWith((message) => updates(message as AmmSwapResponse)) as AmmSwapResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AmmSwapResponse create() => AmmSwapResponse._();
  AmmSwapResponse createEmptyInstance() => create();
  static $pb.PbList<AmmSwapResponse> createRepeated() => $pb.PbList<AmmSwapResponse>();
  @$core.pragma('dart2js:noInline')
  static AmmSwapResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmSwapResponse>(create);
  static AmmSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountReceive => $_getI64(0);
  @$pb.TagNumber(1)
  set amountReceive($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmountReceive() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountReceive() => clearField(1);
}

class GetAmmPoolStateRequest extends $pb.GeneratedMessage {
  factory GetAmmPoolStateRequest({
    $core.String? asset0,
    $core.String? asset1,
  }) {
    final $result = create();
    if (asset0 != null) {
      $result.asset0 = asset0;
    }
    if (asset1 != null) {
      $result.asset1 = asset1;
    }
    return $result;
  }
  GetAmmPoolStateRequest._() : super();
  factory GetAmmPoolStateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAmmPoolStateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPoolStateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAmmPoolStateRequest clone() => GetAmmPoolStateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAmmPoolStateRequest copyWith(void Function(GetAmmPoolStateRequest) updates) => super.copyWith((message) => updates(message as GetAmmPoolStateRequest)) as GetAmmPoolStateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateRequest create() => GetAmmPoolStateRequest._();
  GetAmmPoolStateRequest createEmptyInstance() => create();
  static $pb.PbList<GetAmmPoolStateRequest> createRepeated() => $pb.PbList<GetAmmPoolStateRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPoolStateRequest>(create);
  static GetAmmPoolStateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => clearField(2);
}

class GetAmmPoolStateResponse extends $pb.GeneratedMessage {
  factory GetAmmPoolStateResponse({
    $core.String? poolStateJson,
  }) {
    final $result = create();
    if (poolStateJson != null) {
      $result.poolStateJson = poolStateJson;
    }
    return $result;
  }
  GetAmmPoolStateResponse._() : super();
  factory GetAmmPoolStateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAmmPoolStateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPoolStateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'poolStateJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAmmPoolStateResponse clone() => GetAmmPoolStateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAmmPoolStateResponse copyWith(void Function(GetAmmPoolStateResponse) updates) => super.copyWith((message) => updates(message as GetAmmPoolStateResponse)) as GetAmmPoolStateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateResponse create() => GetAmmPoolStateResponse._();
  GetAmmPoolStateResponse createEmptyInstance() => create();
  static $pb.PbList<GetAmmPoolStateResponse> createRepeated() => $pb.PbList<GetAmmPoolStateResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPoolStateResponse>(create);
  static GetAmmPoolStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get poolStateJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set poolStateJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPoolStateJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPoolStateJson() => clearField(1);
}

class GetAmmPriceRequest extends $pb.GeneratedMessage {
  factory GetAmmPriceRequest({
    $core.String? base,
    $core.String? quote,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (quote != null) {
      $result.quote = quote;
    }
    return $result;
  }
  GetAmmPriceRequest._() : super();
  factory GetAmmPriceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAmmPriceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPriceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'base')
    ..aOS(2, _omitFieldNames ? '' : 'quote')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAmmPriceRequest clone() => GetAmmPriceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAmmPriceRequest copyWith(void Function(GetAmmPriceRequest) updates) => super.copyWith((message) => updates(message as GetAmmPriceRequest)) as GetAmmPriceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAmmPriceRequest create() => GetAmmPriceRequest._();
  GetAmmPriceRequest createEmptyInstance() => create();
  static $pb.PbList<GetAmmPriceRequest> createRepeated() => $pb.PbList<GetAmmPriceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAmmPriceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPriceRequest>(create);
  static GetAmmPriceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get base => $_getSZ(0);
  @$pb.TagNumber(1)
  set base($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get quote => $_getSZ(1);
  @$pb.TagNumber(2)
  set quote($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuote() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuote() => clearField(2);
}

class GetAmmPriceResponse extends $pb.GeneratedMessage {
  factory GetAmmPriceResponse({
    $core.String? priceJson,
  }) {
    final $result = create();
    if (priceJson != null) {
      $result.priceJson = priceJson;
    }
    return $result;
  }
  GetAmmPriceResponse._() : super();
  factory GetAmmPriceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAmmPriceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPriceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'priceJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAmmPriceResponse clone() => GetAmmPriceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAmmPriceResponse copyWith(void Function(GetAmmPriceResponse) updates) => super.copyWith((message) => updates(message as GetAmmPriceResponse)) as GetAmmPriceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAmmPriceResponse create() => GetAmmPriceResponse._();
  GetAmmPriceResponse createEmptyInstance() => create();
  static $pb.PbList<GetAmmPriceResponse> createRepeated() => $pb.PbList<GetAmmPriceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAmmPriceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPriceResponse>(create);
  static GetAmmPriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priceJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set priceJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPriceJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceJson() => clearField(1);
}

class DutchAuctionBidRequest extends $pb.GeneratedMessage {
  factory DutchAuctionBidRequest({
    $core.String? dutchAuctionId,
    $fixnum.Int64? bidSize,
  }) {
    final $result = create();
    if (dutchAuctionId != null) {
      $result.dutchAuctionId = dutchAuctionId;
    }
    if (bidSize != null) {
      $result.bidSize = bidSize;
    }
    return $result;
  }
  DutchAuctionBidRequest._() : super();
  factory DutchAuctionBidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionBidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionBidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dutchAuctionId')
    ..aInt64(2, _omitFieldNames ? '' : 'bidSize')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionBidRequest clone() => DutchAuctionBidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionBidRequest copyWith(void Function(DutchAuctionBidRequest) updates) => super.copyWith((message) => updates(message as DutchAuctionBidRequest)) as DutchAuctionBidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidRequest create() => DutchAuctionBidRequest._();
  DutchAuctionBidRequest createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionBidRequest> createRepeated() => $pb.PbList<DutchAuctionBidRequest>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionBidRequest>(create);
  static DutchAuctionBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dutchAuctionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dutchAuctionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDutchAuctionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDutchAuctionId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get bidSize => $_getI64(1);
  @$pb.TagNumber(2)
  set bidSize($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBidSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBidSize() => clearField(2);
}

class DutchAuctionBidResponse extends $pb.GeneratedMessage {
  factory DutchAuctionBidResponse({
    $fixnum.Int64? baseAmount,
  }) {
    final $result = create();
    if (baseAmount != null) {
      $result.baseAmount = baseAmount;
    }
    return $result;
  }
  DutchAuctionBidResponse._() : super();
  factory DutchAuctionBidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionBidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionBidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'baseAmount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionBidResponse clone() => DutchAuctionBidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionBidResponse copyWith(void Function(DutchAuctionBidResponse) updates) => super.copyWith((message) => updates(message as DutchAuctionBidResponse)) as DutchAuctionBidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidResponse create() => DutchAuctionBidResponse._();
  DutchAuctionBidResponse createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionBidResponse> createRepeated() => $pb.PbList<DutchAuctionBidResponse>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionBidResponse>(create);
  static DutchAuctionBidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get baseAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set baseAmount($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBaseAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAmount() => clearField(1);
}

class DutchAuctionCollectRequest extends $pb.GeneratedMessage {
  factory DutchAuctionCollectRequest({
    $core.String? dutchAuctionId,
  }) {
    final $result = create();
    if (dutchAuctionId != null) {
      $result.dutchAuctionId = dutchAuctionId;
    }
    return $result;
  }
  DutchAuctionCollectRequest._() : super();
  factory DutchAuctionCollectRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionCollectRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCollectRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dutchAuctionId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionCollectRequest clone() => DutchAuctionCollectRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionCollectRequest copyWith(void Function(DutchAuctionCollectRequest) updates) => super.copyWith((message) => updates(message as DutchAuctionCollectRequest)) as DutchAuctionCollectRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectRequest create() => DutchAuctionCollectRequest._();
  DutchAuctionCollectRequest createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionCollectRequest> createRepeated() => $pb.PbList<DutchAuctionCollectRequest>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionCollectRequest>(create);
  static DutchAuctionCollectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dutchAuctionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dutchAuctionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDutchAuctionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDutchAuctionId() => clearField(1);
}

class DutchAuctionCollectResponse extends $pb.GeneratedMessage {
  factory DutchAuctionCollectResponse({
    $fixnum.Int64? baseAmount,
    $fixnum.Int64? quoteAmount,
  }) {
    final $result = create();
    if (baseAmount != null) {
      $result.baseAmount = baseAmount;
    }
    if (quoteAmount != null) {
      $result.quoteAmount = quoteAmount;
    }
    return $result;
  }
  DutchAuctionCollectResponse._() : super();
  factory DutchAuctionCollectResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionCollectResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCollectResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'baseAmount')
    ..aInt64(2, _omitFieldNames ? '' : 'quoteAmount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionCollectResponse clone() => DutchAuctionCollectResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionCollectResponse copyWith(void Function(DutchAuctionCollectResponse) updates) => super.copyWith((message) => updates(message as DutchAuctionCollectResponse)) as DutchAuctionCollectResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectResponse create() => DutchAuctionCollectResponse._();
  DutchAuctionCollectResponse createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionCollectResponse> createRepeated() => $pb.PbList<DutchAuctionCollectResponse>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionCollectResponse>(create);
  static DutchAuctionCollectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get baseAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set baseAmount($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBaseAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAmount() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quoteAmount => $_getI64(1);
  @$pb.TagNumber(2)
  set quoteAmount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuoteAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuoteAmount() => clearField(2);
}

class DutchAuctionCreateRequest extends $pb.GeneratedMessage {
  factory DutchAuctionCreateRequest({
    $fixnum.Int64? startBlock,
    $fixnum.Int64? duration,
    $core.String? baseAsset,
    $fixnum.Int64? baseAmount,
    $core.String? quoteAsset,
    $fixnum.Int64? initialPrice,
    $fixnum.Int64? finalPrice,
  }) {
    final $result = create();
    if (startBlock != null) {
      $result.startBlock = startBlock;
    }
    if (duration != null) {
      $result.duration = duration;
    }
    if (baseAsset != null) {
      $result.baseAsset = baseAsset;
    }
    if (baseAmount != null) {
      $result.baseAmount = baseAmount;
    }
    if (quoteAsset != null) {
      $result.quoteAsset = quoteAsset;
    }
    if (initialPrice != null) {
      $result.initialPrice = initialPrice;
    }
    if (finalPrice != null) {
      $result.finalPrice = finalPrice;
    }
    return $result;
  }
  DutchAuctionCreateRequest._() : super();
  factory DutchAuctionCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'startBlock')
    ..aInt64(2, _omitFieldNames ? '' : 'duration')
    ..aOS(3, _omitFieldNames ? '' : 'baseAsset')
    ..aInt64(4, _omitFieldNames ? '' : 'baseAmount')
    ..aOS(5, _omitFieldNames ? '' : 'quoteAsset')
    ..aInt64(6, _omitFieldNames ? '' : 'initialPrice')
    ..aInt64(7, _omitFieldNames ? '' : 'finalPrice')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionCreateRequest clone() => DutchAuctionCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionCreateRequest copyWith(void Function(DutchAuctionCreateRequest) updates) => super.copyWith((message) => updates(message as DutchAuctionCreateRequest)) as DutchAuctionCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateRequest create() => DutchAuctionCreateRequest._();
  DutchAuctionCreateRequest createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionCreateRequest> createRepeated() => $pb.PbList<DutchAuctionCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionCreateRequest>(create);
  static DutchAuctionCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get startBlock => $_getI64(0);
  @$pb.TagNumber(1)
  set startBlock($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartBlock() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get duration => $_getI64(1);
  @$pb.TagNumber(2)
  set duration($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get baseAsset => $_getSZ(2);
  @$pb.TagNumber(3)
  set baseAsset($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBaseAsset() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaseAsset() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get baseAmount => $_getI64(3);
  @$pb.TagNumber(4)
  set baseAmount($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBaseAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearBaseAmount() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get quoteAsset => $_getSZ(4);
  @$pb.TagNumber(5)
  set quoteAsset($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasQuoteAsset() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuoteAsset() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get initialPrice => $_getI64(5);
  @$pb.TagNumber(6)
  set initialPrice($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInitialPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearInitialPrice() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get finalPrice => $_getI64(6);
  @$pb.TagNumber(7)
  set finalPrice($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFinalPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearFinalPrice() => clearField(7);
}

class DutchAuctionCreateResponse extends $pb.GeneratedMessage {
  factory DutchAuctionCreateResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  DutchAuctionCreateResponse._() : super();
  factory DutchAuctionCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionCreateResponse clone() => DutchAuctionCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionCreateResponse copyWith(void Function(DutchAuctionCreateResponse) updates) => super.copyWith((message) => updates(message as DutchAuctionCreateResponse)) as DutchAuctionCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateResponse create() => DutchAuctionCreateResponse._();
  DutchAuctionCreateResponse createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionCreateResponse> createRepeated() => $pb.PbList<DutchAuctionCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionCreateResponse>(create);
  static DutchAuctionCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class DutchAuctionsRequest extends $pb.GeneratedMessage {
  factory DutchAuctionsRequest() => create();
  DutchAuctionsRequest._() : super();
  factory DutchAuctionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionsRequest clone() => DutchAuctionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionsRequest copyWith(void Function(DutchAuctionsRequest) updates) => super.copyWith((message) => updates(message as DutchAuctionsRequest)) as DutchAuctionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionsRequest create() => DutchAuctionsRequest._();
  DutchAuctionsRequest createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionsRequest> createRepeated() => $pb.PbList<DutchAuctionsRequest>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionsRequest>(create);
  static DutchAuctionsRequest? _defaultInstance;
}

class DutchAuctionsResponse extends $pb.GeneratedMessage {
  factory DutchAuctionsResponse({
    $core.String? auctionsJson,
  }) {
    final $result = create();
    if (auctionsJson != null) {
      $result.auctionsJson = auctionsJson;
    }
    return $result;
  }
  DutchAuctionsResponse._() : super();
  factory DutchAuctionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DutchAuctionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'auctionsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DutchAuctionsResponse clone() => DutchAuctionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DutchAuctionsResponse copyWith(void Function(DutchAuctionsResponse) updates) => super.copyWith((message) => updates(message as DutchAuctionsResponse)) as DutchAuctionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DutchAuctionsResponse create() => DutchAuctionsResponse._();
  DutchAuctionsResponse createEmptyInstance() => create();
  static $pb.PbList<DutchAuctionsResponse> createRepeated() => $pb.PbList<DutchAuctionsResponse>();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DutchAuctionsResponse>(create);
  static DutchAuctionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get auctionsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set auctionsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAuctionsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuctionsJson() => clearField(1);
}

class BitAssetsServiceApi {
  $pb.RpcClient _client;
  BitAssetsServiceApi(this._client);

  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'BitAssetsService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
    _client.invoke<GetBlockCountResponse>(ctx, 'BitAssetsService', 'GetBlockCount', request, GetBlockCountResponse())
  ;
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
    _client.invoke<StopResponse>(ctx, 'BitAssetsService', 'Stop', request, StopResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'BitAssetsService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
    _client.invoke<WithdrawResponse>(ctx, 'BitAssetsService', 'Withdraw', request, WithdrawResponse())
  ;
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
    _client.invoke<TransferResponse>(ctx, 'BitAssetsService', 'Transfer', request, TransferResponse())
  ;
  $async.Future<GetSidechainWealthResponse> getSidechainWealth($pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
    _client.invoke<GetSidechainWealthResponse>(ctx, 'BitAssetsService', 'GetSidechainWealth', request, GetSidechainWealthResponse())
  ;
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
    _client.invoke<CreateDepositResponse>(ctx, 'BitAssetsService', 'CreateDeposit', request, CreateDepositResponse())
  ;
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
    _client.invoke<GetPendingWithdrawalBundleResponse>(ctx, 'BitAssetsService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse())
  ;
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
    _client.invoke<ConnectPeerResponse>(ctx, 'BitAssetsService', 'ConnectPeer', request, ConnectPeerResponse())
  ;
  $async.Future<ForgetPeerResponse> forgetPeer($pb.ClientContext? ctx, ForgetPeerRequest request) =>
    _client.invoke<ForgetPeerResponse>(ctx, 'BitAssetsService', 'ForgetPeer', request, ForgetPeerResponse())
  ;
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
    _client.invoke<ListPeersResponse>(ctx, 'BitAssetsService', 'ListPeers', request, ListPeersResponse())
  ;
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
    _client.invoke<MineResponse>(ctx, 'BitAssetsService', 'Mine', request, MineResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'BitAssetsService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
    _client.invoke<GetBestMainchainBlockHashResponse>(ctx, 'BitAssetsService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse())
  ;
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
    _client.invoke<GetBestSidechainBlockHashResponse>(ctx, 'BitAssetsService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse())
  ;
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
    _client.invoke<GetBmmInclusionsResponse>(ctx, 'BitAssetsService', 'GetBmmInclusions', request, GetBmmInclusionsResponse())
  ;
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) =>
    _client.invoke<GetWalletUtxosResponse>(ctx, 'BitAssetsService', 'GetWalletUtxos', request, GetWalletUtxosResponse())
  ;
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
    _client.invoke<ListUtxosResponse>(ctx, 'BitAssetsService', 'ListUtxos', request, ListUtxosResponse())
  ;
  $async.Future<RemoveFromMempoolResponse> removeFromMempool($pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
    _client.invoke<RemoveFromMempoolResponse>(ctx, 'BitAssetsService', 'RemoveFromMempool', request, RemoveFromMempoolResponse())
  ;
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
    _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'BitAssetsService', 'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse())
  ;
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
    _client.invoke<GenerateMnemonicResponse>(ctx, 'BitAssetsService', 'GenerateMnemonic', request, GenerateMnemonicResponse())
  ;
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
    _client.invoke<SetSeedFromMnemonicResponse>(ctx, 'BitAssetsService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse())
  ;
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
    _client.invoke<CallRawResponse>(ctx, 'BitAssetsService', 'CallRaw', request, CallRawResponse())
  ;
  $async.Future<GetBitAssetDataResponse> getBitAssetData($pb.ClientContext? ctx, GetBitAssetDataRequest request) =>
    _client.invoke<GetBitAssetDataResponse>(ctx, 'BitAssetsService', 'GetBitAssetData', request, GetBitAssetDataResponse())
  ;
  $async.Future<ListBitAssetsResponse> listBitAssets($pb.ClientContext? ctx, ListBitAssetsRequest request) =>
    _client.invoke<ListBitAssetsResponse>(ctx, 'BitAssetsService', 'ListBitAssets', request, ListBitAssetsResponse())
  ;
  $async.Future<RegisterBitAssetResponse> registerBitAsset($pb.ClientContext? ctx, RegisterBitAssetRequest request) =>
    _client.invoke<RegisterBitAssetResponse>(ctx, 'BitAssetsService', 'RegisterBitAsset', request, RegisterBitAssetResponse())
  ;
  $async.Future<ReserveBitAssetResponse> reserveBitAsset($pb.ClientContext? ctx, ReserveBitAssetRequest request) =>
    _client.invoke<ReserveBitAssetResponse>(ctx, 'BitAssetsService', 'ReserveBitAsset', request, ReserveBitAssetResponse())
  ;
  $async.Future<TransferBitAssetResponse> transferBitAsset($pb.ClientContext? ctx, TransferBitAssetRequest request) =>
    _client.invoke<TransferBitAssetResponse>(ctx, 'BitAssetsService', 'TransferBitAsset', request, TransferBitAssetResponse())
  ;
  $async.Future<GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ClientContext? ctx, GetNewEncryptionKeyRequest request) =>
    _client.invoke<GetNewEncryptionKeyResponse>(ctx, 'BitAssetsService', 'GetNewEncryptionKey', request, GetNewEncryptionKeyResponse())
  ;
  $async.Future<GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ClientContext? ctx, GetNewVerifyingKeyRequest request) =>
    _client.invoke<GetNewVerifyingKeyResponse>(ctx, 'BitAssetsService', 'GetNewVerifyingKey', request, GetNewVerifyingKeyResponse())
  ;
  $async.Future<DecryptMsgResponse> decryptMsg($pb.ClientContext? ctx, DecryptMsgRequest request) =>
    _client.invoke<DecryptMsgResponse>(ctx, 'BitAssetsService', 'DecryptMsg', request, DecryptMsgResponse())
  ;
  $async.Future<EncryptMsgResponse> encryptMsg($pb.ClientContext? ctx, EncryptMsgRequest request) =>
    _client.invoke<EncryptMsgResponse>(ctx, 'BitAssetsService', 'EncryptMsg', request, EncryptMsgResponse())
  ;
  $async.Future<SignArbitraryMsgResponse> signArbitraryMsg($pb.ClientContext? ctx, SignArbitraryMsgRequest request) =>
    _client.invoke<SignArbitraryMsgResponse>(ctx, 'BitAssetsService', 'SignArbitraryMsg', request, SignArbitraryMsgResponse())
  ;
  $async.Future<SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ClientContext? ctx, SignArbitraryMsgAsAddrRequest request) =>
    _client.invoke<SignArbitraryMsgAsAddrResponse>(ctx, 'BitAssetsService', 'SignArbitraryMsgAsAddr', request, SignArbitraryMsgAsAddrResponse())
  ;
  $async.Future<VerifySignatureResponse> verifySignature($pb.ClientContext? ctx, VerifySignatureRequest request) =>
    _client.invoke<VerifySignatureResponse>(ctx, 'BitAssetsService', 'VerifySignature', request, VerifySignatureResponse())
  ;
  $async.Future<GetWalletAddressesResponse> getWalletAddresses($pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
    _client.invoke<GetWalletAddressesResponse>(ctx, 'BitAssetsService', 'GetWalletAddresses', request, GetWalletAddressesResponse())
  ;
  $async.Future<MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ClientContext? ctx, MyUnconfirmedUtxosRequest request) =>
    _client.invoke<MyUnconfirmedUtxosResponse>(ctx, 'BitAssetsService', 'MyUnconfirmedUtxos', request, MyUnconfirmedUtxosResponse())
  ;
  $async.Future<OpenapiSchemaResponse> openapiSchema($pb.ClientContext? ctx, OpenapiSchemaRequest request) =>
    _client.invoke<OpenapiSchemaResponse>(ctx, 'BitAssetsService', 'OpenapiSchema', request, OpenapiSchemaResponse())
  ;
  $async.Future<AmmBurnResponse> ammBurn($pb.ClientContext? ctx, AmmBurnRequest request) =>
    _client.invoke<AmmBurnResponse>(ctx, 'BitAssetsService', 'AmmBurn', request, AmmBurnResponse())
  ;
  $async.Future<AmmMintResponse> ammMint($pb.ClientContext? ctx, AmmMintRequest request) =>
    _client.invoke<AmmMintResponse>(ctx, 'BitAssetsService', 'AmmMint', request, AmmMintResponse())
  ;
  $async.Future<AmmSwapResponse> ammSwap($pb.ClientContext? ctx, AmmSwapRequest request) =>
    _client.invoke<AmmSwapResponse>(ctx, 'BitAssetsService', 'AmmSwap', request, AmmSwapResponse())
  ;
  $async.Future<GetAmmPoolStateResponse> getAmmPoolState($pb.ClientContext? ctx, GetAmmPoolStateRequest request) =>
    _client.invoke<GetAmmPoolStateResponse>(ctx, 'BitAssetsService', 'GetAmmPoolState', request, GetAmmPoolStateResponse())
  ;
  $async.Future<GetAmmPriceResponse> getAmmPrice($pb.ClientContext? ctx, GetAmmPriceRequest request) =>
    _client.invoke<GetAmmPriceResponse>(ctx, 'BitAssetsService', 'GetAmmPrice', request, GetAmmPriceResponse())
  ;
  $async.Future<DutchAuctionBidResponse> dutchAuctionBid($pb.ClientContext? ctx, DutchAuctionBidRequest request) =>
    _client.invoke<DutchAuctionBidResponse>(ctx, 'BitAssetsService', 'DutchAuctionBid', request, DutchAuctionBidResponse())
  ;
  $async.Future<DutchAuctionCollectResponse> dutchAuctionCollect($pb.ClientContext? ctx, DutchAuctionCollectRequest request) =>
    _client.invoke<DutchAuctionCollectResponse>(ctx, 'BitAssetsService', 'DutchAuctionCollect', request, DutchAuctionCollectResponse())
  ;
  $async.Future<DutchAuctionCreateResponse> dutchAuctionCreate($pb.ClientContext? ctx, DutchAuctionCreateRequest request) =>
    _client.invoke<DutchAuctionCreateResponse>(ctx, 'BitAssetsService', 'DutchAuctionCreate', request, DutchAuctionCreateResponse())
  ;
  $async.Future<DutchAuctionsResponse> dutchAuctions($pb.ClientContext? ctx, DutchAuctionsRequest request) =>
    _client.invoke<DutchAuctionsResponse>(ctx, 'BitAssetsService', 'DutchAuctions', request, DutchAuctionsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
