//
//  Generated code. Do not modify.
//  source: coinshift/v1/coinshift.proto
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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
    return $result;
  }
  TransferRequest._() : super();
  factory TransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

class GetWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetWalletAddressesRequest() => create();
  GetWalletAddressesRequest._() : super();
  factory GetWalletAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

class OpenapiSchemaRequest extends $pb.GeneratedMessage {
  factory OpenapiSchemaRequest() => create();
  OpenapiSchemaRequest._() : super();
  factory OpenapiSchemaRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenapiSchemaRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
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

class CreateSwapRequest extends $pb.GeneratedMessage {
  factory CreateSwapRequest({
    $fixnum.Int64? l2AmountSats,
    $fixnum.Int64? l1AmountSats,
    $core.String? l1RecipientAddress,
    $core.String? parentChain,
    $core.String? l2Recipient,
    $core.int? requiredConfirmations,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (l2AmountSats != null) {
      $result.l2AmountSats = l2AmountSats;
    }
    if (l1AmountSats != null) {
      $result.l1AmountSats = l1AmountSats;
    }
    if (l1RecipientAddress != null) {
      $result.l1RecipientAddress = l1RecipientAddress;
    }
    if (parentChain != null) {
      $result.parentChain = parentChain;
    }
    if (l2Recipient != null) {
      $result.l2Recipient = l2Recipient;
    }
    if (requiredConfirmations != null) {
      $result.requiredConfirmations = requiredConfirmations;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  CreateSwapRequest._() : super();
  factory CreateSwapRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSwapRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSwapRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'l2AmountSats')
    ..aInt64(2, _omitFieldNames ? '' : 'l1AmountSats')
    ..aOS(3, _omitFieldNames ? '' : 'l1RecipientAddress')
    ..aOS(4, _omitFieldNames ? '' : 'parentChain')
    ..aOS(5, _omitFieldNames ? '' : 'l2Recipient')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'requiredConfirmations', $pb.PbFieldType.O3)
    ..aInt64(7, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSwapRequest clone() => CreateSwapRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSwapRequest copyWith(void Function(CreateSwapRequest) updates) => super.copyWith((message) => updates(message as CreateSwapRequest)) as CreateSwapRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSwapRequest create() => CreateSwapRequest._();
  CreateSwapRequest createEmptyInstance() => create();
  static $pb.PbList<CreateSwapRequest> createRepeated() => $pb.PbList<CreateSwapRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateSwapRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSwapRequest>(create);
  static CreateSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get l2AmountSats => $_getI64(0);
  @$pb.TagNumber(1)
  set l2AmountSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasL2AmountSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearL2AmountSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get l1AmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set l1AmountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasL1AmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1AmountSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get l1RecipientAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set l1RecipientAddress($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasL1RecipientAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearL1RecipientAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentChain => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentChain($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasParentChain() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentChain() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get l2Recipient => $_getSZ(4);
  @$pb.TagNumber(5)
  set l2Recipient($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasL2Recipient() => $_has(4);
  @$pb.TagNumber(5)
  void clearL2Recipient() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get requiredConfirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set requiredConfirmations($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRequiredConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequiredConfirmations() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get feeSats => $_getI64(6);
  @$pb.TagNumber(7)
  set feeSats($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFeeSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeSats() => clearField(7);
}

class CreateSwapResponse extends $pb.GeneratedMessage {
  factory CreateSwapResponse({
    $core.String? swapId,
    $core.String? txid,
  }) {
    final $result = create();
    if (swapId != null) {
      $result.swapId = swapId;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateSwapResponse._() : super();
  factory CreateSwapResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSwapResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSwapResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSwapResponse clone() => CreateSwapResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSwapResponse copyWith(void Function(CreateSwapResponse) updates) => super.copyWith((message) => updates(message as CreateSwapResponse)) as CreateSwapResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSwapResponse create() => CreateSwapResponse._();
  CreateSwapResponse createEmptyInstance() => create();
  static $pb.PbList<CreateSwapResponse> createRepeated() => $pb.PbList<CreateSwapResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateSwapResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSwapResponse>(create);
  static CreateSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

class ClaimSwapRequest extends $pb.GeneratedMessage {
  factory ClaimSwapRequest({
    $core.String? swapId,
    $core.String? l2ClaimerAddress,
  }) {
    final $result = create();
    if (swapId != null) {
      $result.swapId = swapId;
    }
    if (l2ClaimerAddress != null) {
      $result.l2ClaimerAddress = l2ClaimerAddress;
    }
    return $result;
  }
  ClaimSwapRequest._() : super();
  factory ClaimSwapRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClaimSwapRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClaimSwapRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'l2ClaimerAddress')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClaimSwapRequest clone() => ClaimSwapRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClaimSwapRequest copyWith(void Function(ClaimSwapRequest) updates) => super.copyWith((message) => updates(message as ClaimSwapRequest)) as ClaimSwapRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClaimSwapRequest create() => ClaimSwapRequest._();
  ClaimSwapRequest createEmptyInstance() => create();
  static $pb.PbList<ClaimSwapRequest> createRepeated() => $pb.PbList<ClaimSwapRequest>();
  @$core.pragma('dart2js:noInline')
  static ClaimSwapRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClaimSwapRequest>(create);
  static ClaimSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get l2ClaimerAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set l2ClaimerAddress($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasL2ClaimerAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearL2ClaimerAddress() => clearField(2);
}

class ClaimSwapResponse extends $pb.GeneratedMessage {
  factory ClaimSwapResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  ClaimSwapResponse._() : super();
  factory ClaimSwapResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClaimSwapResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClaimSwapResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClaimSwapResponse clone() => ClaimSwapResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClaimSwapResponse copyWith(void Function(ClaimSwapResponse) updates) => super.copyWith((message) => updates(message as ClaimSwapResponse)) as ClaimSwapResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClaimSwapResponse create() => ClaimSwapResponse._();
  ClaimSwapResponse createEmptyInstance() => create();
  static $pb.PbList<ClaimSwapResponse> createRepeated() => $pb.PbList<ClaimSwapResponse>();
  @$core.pragma('dart2js:noInline')
  static ClaimSwapResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClaimSwapResponse>(create);
  static ClaimSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetSwapStatusRequest extends $pb.GeneratedMessage {
  factory GetSwapStatusRequest({
    $core.String? swapId,
  }) {
    final $result = create();
    if (swapId != null) {
      $result.swapId = swapId;
    }
    return $result;
  }
  GetSwapStatusRequest._() : super();
  factory GetSwapStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSwapStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSwapStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSwapStatusRequest clone() => GetSwapStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSwapStatusRequest copyWith(void Function(GetSwapStatusRequest) updates) => super.copyWith((message) => updates(message as GetSwapStatusRequest)) as GetSwapStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSwapStatusRequest create() => GetSwapStatusRequest._();
  GetSwapStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetSwapStatusRequest> createRepeated() => $pb.PbList<GetSwapStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSwapStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSwapStatusRequest>(create);
  static GetSwapStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => clearField(1);
}

class GetSwapStatusResponse extends $pb.GeneratedMessage {
  factory GetSwapStatusResponse({
    $core.String? swapJson,
  }) {
    final $result = create();
    if (swapJson != null) {
      $result.swapJson = swapJson;
    }
    return $result;
  }
  GetSwapStatusResponse._() : super();
  factory GetSwapStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSwapStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSwapStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSwapStatusResponse clone() => GetSwapStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSwapStatusResponse copyWith(void Function(GetSwapStatusResponse) updates) => super.copyWith((message) => updates(message as GetSwapStatusResponse)) as GetSwapStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSwapStatusResponse create() => GetSwapStatusResponse._();
  GetSwapStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetSwapStatusResponse> createRepeated() => $pb.PbList<GetSwapStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSwapStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSwapStatusResponse>(create);
  static GetSwapStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapJson() => clearField(1);
}

class ListSwapsRequest extends $pb.GeneratedMessage {
  factory ListSwapsRequest() => create();
  ListSwapsRequest._() : super();
  factory ListSwapsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSwapsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSwapsRequest clone() => ListSwapsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSwapsRequest copyWith(void Function(ListSwapsRequest) updates) => super.copyWith((message) => updates(message as ListSwapsRequest)) as ListSwapsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSwapsRequest create() => ListSwapsRequest._();
  ListSwapsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSwapsRequest> createRepeated() => $pb.PbList<ListSwapsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSwapsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsRequest>(create);
  static ListSwapsRequest? _defaultInstance;
}

class ListSwapsResponse extends $pb.GeneratedMessage {
  factory ListSwapsResponse({
    $core.String? swapsJson,
  }) {
    final $result = create();
    if (swapsJson != null) {
      $result.swapsJson = swapsJson;
    }
    return $result;
  }
  ListSwapsResponse._() : super();
  factory ListSwapsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSwapsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSwapsResponse clone() => ListSwapsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSwapsResponse copyWith(void Function(ListSwapsResponse) updates) => super.copyWith((message) => updates(message as ListSwapsResponse)) as ListSwapsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSwapsResponse create() => ListSwapsResponse._();
  ListSwapsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSwapsResponse> createRepeated() => $pb.PbList<ListSwapsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSwapsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsResponse>(create);
  static ListSwapsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapsJson() => clearField(1);
}

class ListSwapsByRecipientRequest extends $pb.GeneratedMessage {
  factory ListSwapsByRecipientRequest({
    $core.String? recipient,
  }) {
    final $result = create();
    if (recipient != null) {
      $result.recipient = recipient;
    }
    return $result;
  }
  ListSwapsByRecipientRequest._() : super();
  factory ListSwapsByRecipientRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSwapsByRecipientRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsByRecipientRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipient')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSwapsByRecipientRequest clone() => ListSwapsByRecipientRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSwapsByRecipientRequest copyWith(void Function(ListSwapsByRecipientRequest) updates) => super.copyWith((message) => updates(message as ListSwapsByRecipientRequest)) as ListSwapsByRecipientRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientRequest create() => ListSwapsByRecipientRequest._();
  ListSwapsByRecipientRequest createEmptyInstance() => create();
  static $pb.PbList<ListSwapsByRecipientRequest> createRepeated() => $pb.PbList<ListSwapsByRecipientRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsByRecipientRequest>(create);
  static ListSwapsByRecipientRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipient => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipient($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipient() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipient() => clearField(1);
}

class ListSwapsByRecipientResponse extends $pb.GeneratedMessage {
  factory ListSwapsByRecipientResponse({
    $core.String? swapsJson,
  }) {
    final $result = create();
    if (swapsJson != null) {
      $result.swapsJson = swapsJson;
    }
    return $result;
  }
  ListSwapsByRecipientResponse._() : super();
  factory ListSwapsByRecipientResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSwapsByRecipientResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsByRecipientResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSwapsByRecipientResponse clone() => ListSwapsByRecipientResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSwapsByRecipientResponse copyWith(void Function(ListSwapsByRecipientResponse) updates) => super.copyWith((message) => updates(message as ListSwapsByRecipientResponse)) as ListSwapsByRecipientResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientResponse create() => ListSwapsByRecipientResponse._();
  ListSwapsByRecipientResponse createEmptyInstance() => create();
  static $pb.PbList<ListSwapsByRecipientResponse> createRepeated() => $pb.PbList<ListSwapsByRecipientResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsByRecipientResponse>(create);
  static ListSwapsByRecipientResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapsJson() => clearField(1);
}

class UpdateSwapL1TxidRequest extends $pb.GeneratedMessage {
  factory UpdateSwapL1TxidRequest({
    $core.String? swapId,
    $core.String? l1TxidHex,
    $core.int? confirmations,
  }) {
    final $result = create();
    if (swapId != null) {
      $result.swapId = swapId;
    }
    if (l1TxidHex != null) {
      $result.l1TxidHex = l1TxidHex;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    return $result;
  }
  UpdateSwapL1TxidRequest._() : super();
  factory UpdateSwapL1TxidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSwapL1TxidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSwapL1TxidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'l1TxidHex')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSwapL1TxidRequest clone() => UpdateSwapL1TxidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSwapL1TxidRequest copyWith(void Function(UpdateSwapL1TxidRequest) updates) => super.copyWith((message) => updates(message as UpdateSwapL1TxidRequest)) as UpdateSwapL1TxidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidRequest create() => UpdateSwapL1TxidRequest._();
  UpdateSwapL1TxidRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateSwapL1TxidRequest> createRepeated() => $pb.PbList<UpdateSwapL1TxidRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSwapL1TxidRequest>(create);
  static UpdateSwapL1TxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get l1TxidHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set l1TxidHex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasL1TxidHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1TxidHex() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => clearField(3);
}

class UpdateSwapL1TxidResponse extends $pb.GeneratedMessage {
  factory UpdateSwapL1TxidResponse() => create();
  UpdateSwapL1TxidResponse._() : super();
  factory UpdateSwapL1TxidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSwapL1TxidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSwapL1TxidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSwapL1TxidResponse clone() => UpdateSwapL1TxidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSwapL1TxidResponse copyWith(void Function(UpdateSwapL1TxidResponse) updates) => super.copyWith((message) => updates(message as UpdateSwapL1TxidResponse)) as UpdateSwapL1TxidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidResponse create() => UpdateSwapL1TxidResponse._();
  UpdateSwapL1TxidResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateSwapL1TxidResponse> createRepeated() => $pb.PbList<UpdateSwapL1TxidResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSwapL1TxidResponse>(create);
  static UpdateSwapL1TxidResponse? _defaultInstance;
}

class ReconstructSwapsRequest extends $pb.GeneratedMessage {
  factory ReconstructSwapsRequest() => create();
  ReconstructSwapsRequest._() : super();
  factory ReconstructSwapsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconstructSwapsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconstructSwapsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconstructSwapsRequest clone() => ReconstructSwapsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconstructSwapsRequest copyWith(void Function(ReconstructSwapsRequest) updates) => super.copyWith((message) => updates(message as ReconstructSwapsRequest)) as ReconstructSwapsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsRequest create() => ReconstructSwapsRequest._();
  ReconstructSwapsRequest createEmptyInstance() => create();
  static $pb.PbList<ReconstructSwapsRequest> createRepeated() => $pb.PbList<ReconstructSwapsRequest>();
  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconstructSwapsRequest>(create);
  static ReconstructSwapsRequest? _defaultInstance;
}

class ReconstructSwapsResponse extends $pb.GeneratedMessage {
  factory ReconstructSwapsResponse({
    $fixnum.Int64? count,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  ReconstructSwapsResponse._() : super();
  factory ReconstructSwapsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconstructSwapsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconstructSwapsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconstructSwapsResponse clone() => ReconstructSwapsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconstructSwapsResponse copyWith(void Function(ReconstructSwapsResponse) updates) => super.copyWith((message) => updates(message as ReconstructSwapsResponse)) as ReconstructSwapsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsResponse create() => ReconstructSwapsResponse._();
  ReconstructSwapsResponse createEmptyInstance() => create();
  static $pb.PbList<ReconstructSwapsResponse> createRepeated() => $pb.PbList<ReconstructSwapsResponse>();
  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconstructSwapsResponse>(create);
  static ReconstructSwapsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => clearField(1);
}

class CoinShiftServiceApi {
  $pb.RpcClient _client;
  CoinShiftServiceApi(this._client);

  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'CoinShiftService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
    _client.invoke<GetBlockCountResponse>(ctx, 'CoinShiftService', 'GetBlockCount', request, GetBlockCountResponse())
  ;
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
    _client.invoke<StopResponse>(ctx, 'CoinShiftService', 'Stop', request, StopResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'CoinShiftService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
    _client.invoke<WithdrawResponse>(ctx, 'CoinShiftService', 'Withdraw', request, WithdrawResponse())
  ;
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
    _client.invoke<TransferResponse>(ctx, 'CoinShiftService', 'Transfer', request, TransferResponse())
  ;
  $async.Future<GetSidechainWealthResponse> getSidechainWealth($pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
    _client.invoke<GetSidechainWealthResponse>(ctx, 'CoinShiftService', 'GetSidechainWealth', request, GetSidechainWealthResponse())
  ;
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
    _client.invoke<CreateDepositResponse>(ctx, 'CoinShiftService', 'CreateDeposit', request, CreateDepositResponse())
  ;
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
    _client.invoke<GetPendingWithdrawalBundleResponse>(ctx, 'CoinShiftService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse())
  ;
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
    _client.invoke<ConnectPeerResponse>(ctx, 'CoinShiftService', 'ConnectPeer', request, ConnectPeerResponse())
  ;
  $async.Future<ForgetPeerResponse> forgetPeer($pb.ClientContext? ctx, ForgetPeerRequest request) =>
    _client.invoke<ForgetPeerResponse>(ctx, 'CoinShiftService', 'ForgetPeer', request, ForgetPeerResponse())
  ;
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
    _client.invoke<ListPeersResponse>(ctx, 'CoinShiftService', 'ListPeers', request, ListPeersResponse())
  ;
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
    _client.invoke<MineResponse>(ctx, 'CoinShiftService', 'Mine', request, MineResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'CoinShiftService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
    _client.invoke<GetBestMainchainBlockHashResponse>(ctx, 'CoinShiftService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse())
  ;
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
    _client.invoke<GetBestSidechainBlockHashResponse>(ctx, 'CoinShiftService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse())
  ;
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
    _client.invoke<GetBmmInclusionsResponse>(ctx, 'CoinShiftService', 'GetBmmInclusions', request, GetBmmInclusionsResponse())
  ;
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) =>
    _client.invoke<GetWalletUtxosResponse>(ctx, 'CoinShiftService', 'GetWalletUtxos', request, GetWalletUtxosResponse())
  ;
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
    _client.invoke<ListUtxosResponse>(ctx, 'CoinShiftService', 'ListUtxos', request, ListUtxosResponse())
  ;
  $async.Future<RemoveFromMempoolResponse> removeFromMempool($pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
    _client.invoke<RemoveFromMempoolResponse>(ctx, 'CoinShiftService', 'RemoveFromMempool', request, RemoveFromMempoolResponse())
  ;
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
    _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'CoinShiftService', 'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse())
  ;
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
    _client.invoke<GenerateMnemonicResponse>(ctx, 'CoinShiftService', 'GenerateMnemonic', request, GenerateMnemonicResponse())
  ;
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
    _client.invoke<SetSeedFromMnemonicResponse>(ctx, 'CoinShiftService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse())
  ;
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
    _client.invoke<CallRawResponse>(ctx, 'CoinShiftService', 'CallRaw', request, CallRawResponse())
  ;
  $async.Future<GetWalletAddressesResponse> getWalletAddresses($pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
    _client.invoke<GetWalletAddressesResponse>(ctx, 'CoinShiftService', 'GetWalletAddresses', request, GetWalletAddressesResponse())
  ;
  $async.Future<OpenapiSchemaResponse> openapiSchema($pb.ClientContext? ctx, OpenapiSchemaRequest request) =>
    _client.invoke<OpenapiSchemaResponse>(ctx, 'CoinShiftService', 'OpenapiSchema', request, OpenapiSchemaResponse())
  ;
  $async.Future<CreateSwapResponse> createSwap($pb.ClientContext? ctx, CreateSwapRequest request) =>
    _client.invoke<CreateSwapResponse>(ctx, 'CoinShiftService', 'CreateSwap', request, CreateSwapResponse())
  ;
  $async.Future<ClaimSwapResponse> claimSwap($pb.ClientContext? ctx, ClaimSwapRequest request) =>
    _client.invoke<ClaimSwapResponse>(ctx, 'CoinShiftService', 'ClaimSwap', request, ClaimSwapResponse())
  ;
  $async.Future<GetSwapStatusResponse> getSwapStatus($pb.ClientContext? ctx, GetSwapStatusRequest request) =>
    _client.invoke<GetSwapStatusResponse>(ctx, 'CoinShiftService', 'GetSwapStatus', request, GetSwapStatusResponse())
  ;
  $async.Future<ListSwapsResponse> listSwaps($pb.ClientContext? ctx, ListSwapsRequest request) =>
    _client.invoke<ListSwapsResponse>(ctx, 'CoinShiftService', 'ListSwaps', request, ListSwapsResponse())
  ;
  $async.Future<ListSwapsByRecipientResponse> listSwapsByRecipient($pb.ClientContext? ctx, ListSwapsByRecipientRequest request) =>
    _client.invoke<ListSwapsByRecipientResponse>(ctx, 'CoinShiftService', 'ListSwapsByRecipient', request, ListSwapsByRecipientResponse())
  ;
  $async.Future<UpdateSwapL1TxidResponse> updateSwapL1Txid($pb.ClientContext? ctx, UpdateSwapL1TxidRequest request) =>
    _client.invoke<UpdateSwapL1TxidResponse>(ctx, 'CoinShiftService', 'UpdateSwapL1Txid', request, UpdateSwapL1TxidResponse())
  ;
  $async.Future<ReconstructSwapsResponse> reconstructSwaps($pb.ClientContext? ctx, ReconstructSwapsRequest request) =>
    _client.invoke<ReconstructSwapsResponse>(ctx, 'CoinShiftService', 'ReconstructSwaps', request, ReconstructSwapsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
