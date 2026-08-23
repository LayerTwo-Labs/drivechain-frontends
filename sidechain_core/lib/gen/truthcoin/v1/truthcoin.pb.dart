//
//  Generated code. Do not modify.
//  source: truthcoin/v1/truthcoin.proto
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

class ListPeersRequest extends $pb.GeneratedMessage {
  factory ListPeersRequest() => create();
  ListPeersRequest._() : super();
  factory ListPeersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPeersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

class RefreshWalletRequest extends $pb.GeneratedMessage {
  factory RefreshWalletRequest() => create();
  RefreshWalletRequest._() : super();
  factory RefreshWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefreshWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefreshWalletRequest clone() => RefreshWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefreshWalletRequest copyWith(void Function(RefreshWalletRequest) updates) => super.copyWith((message) => updates(message as RefreshWalletRequest)) as RefreshWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshWalletRequest create() => RefreshWalletRequest._();
  RefreshWalletRequest createEmptyInstance() => create();
  static $pb.PbList<RefreshWalletRequest> createRepeated() => $pb.PbList<RefreshWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static RefreshWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshWalletRequest>(create);
  static RefreshWalletRequest? _defaultInstance;
}

class RefreshWalletResponse extends $pb.GeneratedMessage {
  factory RefreshWalletResponse() => create();
  RefreshWalletResponse._() : super();
  factory RefreshWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefreshWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefreshWalletResponse clone() => RefreshWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefreshWalletResponse copyWith(void Function(RefreshWalletResponse) updates) => super.copyWith((message) => updates(message as RefreshWalletResponse)) as RefreshWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshWalletResponse create() => RefreshWalletResponse._();
  RefreshWalletResponse createEmptyInstance() => create();
  static $pb.PbList<RefreshWalletResponse> createRepeated() => $pb.PbList<RefreshWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static RefreshWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshWalletResponse>(create);
  static RefreshWalletResponse? _defaultInstance;
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionRequest._() : super();
  factory GetTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionRequest clone() => GetTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionRequest copyWith(void Function(GetTransactionRequest) updates) => super.copyWith((message) => updates(message as GetTransactionRequest)) as GetTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest create() => GetTransactionRequest._();
  GetTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionRequest> createRepeated() => $pb.PbList<GetTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(create);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    $core.String? transactionJson,
  }) {
    final $result = create();
    if (transactionJson != null) {
      $result.transactionJson = transactionJson;
    }
    return $result;
  }
  GetTransactionResponse._() : super();
  factory GetTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transactionJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionResponse clone() => GetTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionResponse copyWith(void Function(GetTransactionResponse) updates) => super.copyWith((message) => updates(message as GetTransactionResponse)) as GetTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse create() => GetTransactionResponse._();
  GetTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionResponse> createRepeated() => $pb.PbList<GetTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(create);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransactionJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionJson() => clearField(1);
}

class GetTransactionInfoRequest extends $pb.GeneratedMessage {
  factory GetTransactionInfoRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionInfoRequest._() : super();
  factory GetTransactionInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionInfoRequest clone() => GetTransactionInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionInfoRequest copyWith(void Function(GetTransactionInfoRequest) updates) => super.copyWith((message) => updates(message as GetTransactionInfoRequest)) as GetTransactionInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoRequest create() => GetTransactionInfoRequest._();
  GetTransactionInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionInfoRequest> createRepeated() => $pb.PbList<GetTransactionInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionInfoRequest>(create);
  static GetTransactionInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetTransactionInfoResponse extends $pb.GeneratedMessage {
  factory GetTransactionInfoResponse({
    $core.String? transactionInfoJson,
  }) {
    final $result = create();
    if (transactionInfoJson != null) {
      $result.transactionInfoJson = transactionInfoJson;
    }
    return $result;
  }
  GetTransactionInfoResponse._() : super();
  factory GetTransactionInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transactionInfoJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionInfoResponse clone() => GetTransactionInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionInfoResponse copyWith(void Function(GetTransactionInfoResponse) updates) => super.copyWith((message) => updates(message as GetTransactionInfoResponse)) as GetTransactionInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoResponse create() => GetTransactionInfoResponse._();
  GetTransactionInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionInfoResponse> createRepeated() => $pb.PbList<GetTransactionInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionInfoResponse>(create);
  static GetTransactionInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionInfoJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionInfoJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransactionInfoJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionInfoJson() => clearField(1);
}

class GetWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetWalletAddressesRequest() => create();
  GetWalletAddressesRequest._() : super();
  factory GetWalletAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

class MyUtxosRequest extends $pb.GeneratedMessage {
  factory MyUtxosRequest() => create();
  MyUtxosRequest._() : super();
  factory MyUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyUtxosRequest clone() => MyUtxosRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyUtxosRequest copyWith(void Function(MyUtxosRequest) updates) => super.copyWith((message) => updates(message as MyUtxosRequest)) as MyUtxosRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyUtxosRequest create() => MyUtxosRequest._();
  MyUtxosRequest createEmptyInstance() => create();
  static $pb.PbList<MyUtxosRequest> createRepeated() => $pb.PbList<MyUtxosRequest>();
  @$core.pragma('dart2js:noInline')
  static MyUtxosRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUtxosRequest>(create);
  static MyUtxosRequest? _defaultInstance;
}

class MyUtxosResponse extends $pb.GeneratedMessage {
  factory MyUtxosResponse({
    $core.String? utxosJson,
  }) {
    final $result = create();
    if (utxosJson != null) {
      $result.utxosJson = utxosJson;
    }
    return $result;
  }
  MyUtxosResponse._() : super();
  factory MyUtxosResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUtxosResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyUtxosResponse clone() => MyUtxosResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyUtxosResponse copyWith(void Function(MyUtxosResponse) updates) => super.copyWith((message) => updates(message as MyUtxosResponse)) as MyUtxosResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyUtxosResponse create() => MyUtxosResponse._();
  MyUtxosResponse createEmptyInstance() => create();
  static $pb.PbList<MyUtxosResponse> createRepeated() => $pb.PbList<MyUtxosResponse>();
  @$core.pragma('dart2js:noInline')
  static MyUtxosResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUtxosResponse>(create);
  static MyUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => clearField(1);
}

class MyUnconfirmedUtxosRequest extends $pb.GeneratedMessage {
  factory MyUnconfirmedUtxosRequest() => create();
  MyUnconfirmedUtxosRequest._() : super();
  factory MyUnconfirmedUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyUnconfirmedUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

class CalculateInitialLiquidityRequest extends $pb.GeneratedMessage {
  factory CalculateInitialLiquidityRequest({
    $core.double? beta,
    $core.int? numOutcomes,
    $core.String? dimensions,
  }) {
    final $result = create();
    if (beta != null) {
      $result.beta = beta;
    }
    if (numOutcomes != null) {
      $result.numOutcomes = numOutcomes;
    }
    if (dimensions != null) {
      $result.dimensions = dimensions;
    }
    return $result;
  }
  CalculateInitialLiquidityRequest._() : super();
  factory CalculateInitialLiquidityRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalculateInitialLiquidityRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateInitialLiquidityRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'beta', $pb.PbFieldType.OD)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'numOutcomes', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'dimensions')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalculateInitialLiquidityRequest clone() => CalculateInitialLiquidityRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalculateInitialLiquidityRequest copyWith(void Function(CalculateInitialLiquidityRequest) updates) => super.copyWith((message) => updates(message as CalculateInitialLiquidityRequest)) as CalculateInitialLiquidityRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityRequest create() => CalculateInitialLiquidityRequest._();
  CalculateInitialLiquidityRequest createEmptyInstance() => create();
  static $pb.PbList<CalculateInitialLiquidityRequest> createRepeated() => $pb.PbList<CalculateInitialLiquidityRequest>();
  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateInitialLiquidityRequest>(create);
  static CalculateInitialLiquidityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get beta => $_getN(0);
  @$pb.TagNumber(1)
  set beta($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBeta() => $_has(0);
  @$pb.TagNumber(1)
  void clearBeta() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get numOutcomes => $_getIZ(1);
  @$pb.TagNumber(2)
  set numOutcomes($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNumOutcomes() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumOutcomes() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get dimensions => $_getSZ(2);
  @$pb.TagNumber(3)
  set dimensions($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDimensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearDimensions() => clearField(3);
}

class CalculateInitialLiquidityResponse extends $pb.GeneratedMessage {
  factory CalculateInitialLiquidityResponse({
    $core.String? resultJson,
  }) {
    final $result = create();
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    return $result;
  }
  CalculateInitialLiquidityResponse._() : super();
  factory CalculateInitialLiquidityResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalculateInitialLiquidityResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateInitialLiquidityResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalculateInitialLiquidityResponse clone() => CalculateInitialLiquidityResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalculateInitialLiquidityResponse copyWith(void Function(CalculateInitialLiquidityResponse) updates) => super.copyWith((message) => updates(message as CalculateInitialLiquidityResponse)) as CalculateInitialLiquidityResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityResponse create() => CalculateInitialLiquidityResponse._();
  CalculateInitialLiquidityResponse createEmptyInstance() => create();
  static $pb.PbList<CalculateInitialLiquidityResponse> createRepeated() => $pb.PbList<CalculateInitialLiquidityResponse>();
  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateInitialLiquidityResponse>(create);
  static CalculateInitialLiquidityResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class MarketCreateRequest extends $pb.GeneratedMessage {
  factory MarketCreateRequest({
    $core.String? title,
    $core.String? description,
    $core.String? dimensions,
    $fixnum.Int64? feeSats,
    $core.double? beta,
    $fixnum.Int64? initialLiquidity,
    $core.double? tradingFee,
    $core.Iterable<$core.String>? tags,
    $core.Iterable<$core.String>? categoryTxids,
    $core.Iterable<$core.String>? residualNames,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (dimensions != null) {
      $result.dimensions = dimensions;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (beta != null) {
      $result.beta = beta;
    }
    if (initialLiquidity != null) {
      $result.initialLiquidity = initialLiquidity;
    }
    if (tradingFee != null) {
      $result.tradingFee = tradingFee;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    if (categoryTxids != null) {
      $result.categoryTxids.addAll(categoryTxids);
    }
    if (residualNames != null) {
      $result.residualNames.addAll(residualNames);
    }
    return $result;
  }
  MarketCreateRequest._() : super();
  factory MarketCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'dimensions')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'beta', $pb.PbFieldType.OD)
    ..aInt64(6, _omitFieldNames ? '' : 'initialLiquidity')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'tradingFee', $pb.PbFieldType.OD)
    ..pPS(8, _omitFieldNames ? '' : 'tags')
    ..pPS(9, _omitFieldNames ? '' : 'categoryTxids')
    ..pPS(10, _omitFieldNames ? '' : 'residualNames')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketCreateRequest clone() => MarketCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketCreateRequest copyWith(void Function(MarketCreateRequest) updates) => super.copyWith((message) => updates(message as MarketCreateRequest)) as MarketCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketCreateRequest create() => MarketCreateRequest._();
  MarketCreateRequest createEmptyInstance() => create();
  static $pb.PbList<MarketCreateRequest> createRepeated() => $pb.PbList<MarketCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketCreateRequest>(create);
  static MarketCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get dimensions => $_getSZ(2);
  @$pb.TagNumber(3)
  set dimensions($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDimensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearDimensions() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get beta => $_getN(4);
  @$pb.TagNumber(5)
  set beta($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBeta() => $_has(4);
  @$pb.TagNumber(5)
  void clearBeta() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get initialLiquidity => $_getI64(5);
  @$pb.TagNumber(6)
  set initialLiquidity($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInitialLiquidity() => $_has(5);
  @$pb.TagNumber(6)
  void clearInitialLiquidity() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get tradingFee => $_getN(6);
  @$pb.TagNumber(7)
  set tradingFee($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTradingFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearTradingFee() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get tags => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<$core.String> get categoryTxids => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<$core.String> get residualNames => $_getList(9);
}

class MarketCreateResponse extends $pb.GeneratedMessage {
  factory MarketCreateResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  MarketCreateResponse._() : super();
  factory MarketCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketCreateResponse clone() => MarketCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketCreateResponse copyWith(void Function(MarketCreateResponse) updates) => super.copyWith((message) => updates(message as MarketCreateResponse)) as MarketCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketCreateResponse create() => MarketCreateResponse._();
  MarketCreateResponse createEmptyInstance() => create();
  static $pb.PbList<MarketCreateResponse> createRepeated() => $pb.PbList<MarketCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketCreateResponse>(create);
  static MarketCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class MarketListRequest extends $pb.GeneratedMessage {
  factory MarketListRequest() => create();
  MarketListRequest._() : super();
  factory MarketListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketListRequest clone() => MarketListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketListRequest copyWith(void Function(MarketListRequest) updates) => super.copyWith((message) => updates(message as MarketListRequest)) as MarketListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketListRequest create() => MarketListRequest._();
  MarketListRequest createEmptyInstance() => create();
  static $pb.PbList<MarketListRequest> createRepeated() => $pb.PbList<MarketListRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketListRequest>(create);
  static MarketListRequest? _defaultInstance;
}

class MarketListResponse extends $pb.GeneratedMessage {
  factory MarketListResponse({
    $core.String? marketsJson,
  }) {
    final $result = create();
    if (marketsJson != null) {
      $result.marketsJson = marketsJson;
    }
    return $result;
  }
  MarketListResponse._() : super();
  factory MarketListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'marketsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketListResponse clone() => MarketListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketListResponse copyWith(void Function(MarketListResponse) updates) => super.copyWith((message) => updates(message as MarketListResponse)) as MarketListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketListResponse create() => MarketListResponse._();
  MarketListResponse createEmptyInstance() => create();
  static $pb.PbList<MarketListResponse> createRepeated() => $pb.PbList<MarketListResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketListResponse>(create);
  static MarketListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMarketsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketsJson() => clearField(1);
}

class MarketGetRequest extends $pb.GeneratedMessage {
  factory MarketGetRequest({
    $core.String? marketId,
  }) {
    final $result = create();
    if (marketId != null) {
      $result.marketId = marketId;
    }
    return $result;
  }
  MarketGetRequest._() : super();
  factory MarketGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketGetRequest clone() => MarketGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketGetRequest copyWith(void Function(MarketGetRequest) updates) => super.copyWith((message) => updates(message as MarketGetRequest)) as MarketGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketGetRequest create() => MarketGetRequest._();
  MarketGetRequest createEmptyInstance() => create();
  static $pb.PbList<MarketGetRequest> createRepeated() => $pb.PbList<MarketGetRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketGetRequest>(create);
  static MarketGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => clearField(1);
}

class MarketGetResponse extends $pb.GeneratedMessage {
  factory MarketGetResponse({
    $core.String? marketJson,
  }) {
    final $result = create();
    if (marketJson != null) {
      $result.marketJson = marketJson;
    }
    return $result;
  }
  MarketGetResponse._() : super();
  factory MarketGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'marketJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketGetResponse clone() => MarketGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketGetResponse copyWith(void Function(MarketGetResponse) updates) => super.copyWith((message) => updates(message as MarketGetResponse)) as MarketGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketGetResponse create() => MarketGetResponse._();
  MarketGetResponse createEmptyInstance() => create();
  static $pb.PbList<MarketGetResponse> createRepeated() => $pb.PbList<MarketGetResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketGetResponse>(create);
  static MarketGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMarketJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketJson() => clearField(1);
}

class MarketBuyRequest extends $pb.GeneratedMessage {
  factory MarketBuyRequest({
    $core.String? marketId,
    $core.int? outcomeIndex,
    $core.double? sharesAmount,
    $core.bool? dryRun,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? maxCost,
  }) {
    final $result = create();
    if (marketId != null) {
      $result.marketId = marketId;
    }
    if (outcomeIndex != null) {
      $result.outcomeIndex = outcomeIndex;
    }
    if (sharesAmount != null) {
      $result.sharesAmount = sharesAmount;
    }
    if (dryRun != null) {
      $result.dryRun = dryRun;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (maxCost != null) {
      $result.maxCost = maxCost;
    }
    return $result;
  }
  MarketBuyRequest._() : super();
  factory MarketBuyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketBuyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketBuyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'outcomeIndex', $pb.PbFieldType.O3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'sharesAmount', $pb.PbFieldType.OD)
    ..aOB(4, _omitFieldNames ? '' : 'dryRun')
    ..aInt64(5, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(6, _omitFieldNames ? '' : 'maxCost')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketBuyRequest clone() => MarketBuyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketBuyRequest copyWith(void Function(MarketBuyRequest) updates) => super.copyWith((message) => updates(message as MarketBuyRequest)) as MarketBuyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketBuyRequest create() => MarketBuyRequest._();
  MarketBuyRequest createEmptyInstance() => create();
  static $pb.PbList<MarketBuyRequest> createRepeated() => $pb.PbList<MarketBuyRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketBuyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketBuyRequest>(create);
  static MarketBuyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get outcomeIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outcomeIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutcomeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutcomeIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get sharesAmount => $_getN(2);
  @$pb.TagNumber(3)
  set sharesAmount($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSharesAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSharesAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get dryRun => $_getBF(3);
  @$pb.TagNumber(4)
  set dryRun($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDryRun() => $_has(3);
  @$pb.TagNumber(4)
  void clearDryRun() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get maxCost => $_getI64(5);
  @$pb.TagNumber(6)
  set maxCost($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxCost() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxCost() => clearField(6);
}

class MarketBuyResponse extends $pb.GeneratedMessage {
  factory MarketBuyResponse({
    $core.String? resultJson,
  }) {
    final $result = create();
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    return $result;
  }
  MarketBuyResponse._() : super();
  factory MarketBuyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketBuyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketBuyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketBuyResponse clone() => MarketBuyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketBuyResponse copyWith(void Function(MarketBuyResponse) updates) => super.copyWith((message) => updates(message as MarketBuyResponse)) as MarketBuyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketBuyResponse create() => MarketBuyResponse._();
  MarketBuyResponse createEmptyInstance() => create();
  static $pb.PbList<MarketBuyResponse> createRepeated() => $pb.PbList<MarketBuyResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketBuyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketBuyResponse>(create);
  static MarketBuyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class MarketSellRequest extends $pb.GeneratedMessage {
  factory MarketSellRequest({
    $core.String? marketId,
    $core.int? outcomeIndex,
    $fixnum.Int64? sharesAmount,
    $core.String? sellerAddress,
    $core.bool? dryRun,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? minProceeds,
  }) {
    final $result = create();
    if (marketId != null) {
      $result.marketId = marketId;
    }
    if (outcomeIndex != null) {
      $result.outcomeIndex = outcomeIndex;
    }
    if (sharesAmount != null) {
      $result.sharesAmount = sharesAmount;
    }
    if (sellerAddress != null) {
      $result.sellerAddress = sellerAddress;
    }
    if (dryRun != null) {
      $result.dryRun = dryRun;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (minProceeds != null) {
      $result.minProceeds = minProceeds;
    }
    return $result;
  }
  MarketSellRequest._() : super();
  factory MarketSellRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketSellRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketSellRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'outcomeIndex', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'sharesAmount')
    ..aOS(4, _omitFieldNames ? '' : 'sellerAddress')
    ..aOB(5, _omitFieldNames ? '' : 'dryRun')
    ..aInt64(6, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(7, _omitFieldNames ? '' : 'minProceeds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketSellRequest clone() => MarketSellRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketSellRequest copyWith(void Function(MarketSellRequest) updates) => super.copyWith((message) => updates(message as MarketSellRequest)) as MarketSellRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketSellRequest create() => MarketSellRequest._();
  MarketSellRequest createEmptyInstance() => create();
  static $pb.PbList<MarketSellRequest> createRepeated() => $pb.PbList<MarketSellRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketSellRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketSellRequest>(create);
  static MarketSellRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get outcomeIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outcomeIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutcomeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutcomeIndex() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sharesAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set sharesAmount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSharesAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSharesAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get sellerAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set sellerAddress($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSellerAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearSellerAddress() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get dryRun => $_getBF(4);
  @$pb.TagNumber(5)
  set dryRun($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDryRun() => $_has(4);
  @$pb.TagNumber(5)
  void clearDryRun() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get feeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSats() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get minProceeds => $_getI64(6);
  @$pb.TagNumber(7)
  set minProceeds($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMinProceeds() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinProceeds() => clearField(7);
}

class MarketSellResponse extends $pb.GeneratedMessage {
  factory MarketSellResponse({
    $core.String? resultJson,
  }) {
    final $result = create();
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    return $result;
  }
  MarketSellResponse._() : super();
  factory MarketSellResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketSellResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketSellResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketSellResponse clone() => MarketSellResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketSellResponse copyWith(void Function(MarketSellResponse) updates) => super.copyWith((message) => updates(message as MarketSellResponse)) as MarketSellResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketSellResponse create() => MarketSellResponse._();
  MarketSellResponse createEmptyInstance() => create();
  static $pb.PbList<MarketSellResponse> createRepeated() => $pb.PbList<MarketSellResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketSellResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketSellResponse>(create);
  static MarketSellResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class MarketPositionsRequest extends $pb.GeneratedMessage {
  factory MarketPositionsRequest({
    $core.String? address,
    $core.String? marketId,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (marketId != null) {
      $result.marketId = marketId;
    }
    return $result;
  }
  MarketPositionsRequest._() : super();
  factory MarketPositionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketPositionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketPositionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketPositionsRequest clone() => MarketPositionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketPositionsRequest copyWith(void Function(MarketPositionsRequest) updates) => super.copyWith((message) => updates(message as MarketPositionsRequest)) as MarketPositionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketPositionsRequest create() => MarketPositionsRequest._();
  MarketPositionsRequest createEmptyInstance() => create();
  static $pb.PbList<MarketPositionsRequest> createRepeated() => $pb.PbList<MarketPositionsRequest>();
  @$core.pragma('dart2js:noInline')
  static MarketPositionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketPositionsRequest>(create);
  static MarketPositionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => clearField(2);
}

class MarketPositionsResponse extends $pb.GeneratedMessage {
  factory MarketPositionsResponse({
    $core.String? positionsJson,
  }) {
    final $result = create();
    if (positionsJson != null) {
      $result.positionsJson = positionsJson;
    }
    return $result;
  }
  MarketPositionsResponse._() : super();
  factory MarketPositionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarketPositionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketPositionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'positionsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarketPositionsResponse clone() => MarketPositionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarketPositionsResponse copyWith(void Function(MarketPositionsResponse) updates) => super.copyWith((message) => updates(message as MarketPositionsResponse)) as MarketPositionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketPositionsResponse create() => MarketPositionsResponse._();
  MarketPositionsResponse createEmptyInstance() => create();
  static $pb.PbList<MarketPositionsResponse> createRepeated() => $pb.PbList<MarketPositionsResponse>();
  @$core.pragma('dart2js:noInline')
  static MarketPositionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketPositionsResponse>(create);
  static MarketPositionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get positionsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set positionsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPositionsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPositionsJson() => clearField(1);
}

class SlotStatusRequest extends $pb.GeneratedMessage {
  factory SlotStatusRequest() => create();
  SlotStatusRequest._() : super();
  factory SlotStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotStatusRequest clone() => SlotStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotStatusRequest copyWith(void Function(SlotStatusRequest) updates) => super.copyWith((message) => updates(message as SlotStatusRequest)) as SlotStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotStatusRequest create() => SlotStatusRequest._();
  SlotStatusRequest createEmptyInstance() => create();
  static $pb.PbList<SlotStatusRequest> createRepeated() => $pb.PbList<SlotStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static SlotStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotStatusRequest>(create);
  static SlotStatusRequest? _defaultInstance;
}

class SlotStatusResponse extends $pb.GeneratedMessage {
  factory SlotStatusResponse({
    $core.String? statusJson,
  }) {
    final $result = create();
    if (statusJson != null) {
      $result.statusJson = statusJson;
    }
    return $result;
  }
  SlotStatusResponse._() : super();
  factory SlotStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'statusJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotStatusResponse clone() => SlotStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotStatusResponse copyWith(void Function(SlotStatusResponse) updates) => super.copyWith((message) => updates(message as SlotStatusResponse)) as SlotStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotStatusResponse create() => SlotStatusResponse._();
  SlotStatusResponse createEmptyInstance() => create();
  static $pb.PbList<SlotStatusResponse> createRepeated() => $pb.PbList<SlotStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static SlotStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotStatusResponse>(create);
  static SlotStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get statusJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set statusJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatusJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusJson() => clearField(1);
}

class SlotListRequest extends $pb.GeneratedMessage {
  factory SlotListRequest({
    $core.int? period,
    $core.String? status,
  }) {
    final $result = create();
    if (period != null) {
      $result.period = period;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  SlotListRequest._() : super();
  factory SlotListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'period', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotListRequest clone() => SlotListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotListRequest copyWith(void Function(SlotListRequest) updates) => super.copyWith((message) => updates(message as SlotListRequest)) as SlotListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotListRequest create() => SlotListRequest._();
  SlotListRequest createEmptyInstance() => create();
  static $pb.PbList<SlotListRequest> createRepeated() => $pb.PbList<SlotListRequest>();
  @$core.pragma('dart2js:noInline')
  static SlotListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotListRequest>(create);
  static SlotListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get period => $_getIZ(0);
  @$pb.TagNumber(1)
  set period($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeriod() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriod() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);
}

class SlotListResponse extends $pb.GeneratedMessage {
  factory SlotListResponse({
    $core.String? slotsJson,
  }) {
    final $result = create();
    if (slotsJson != null) {
      $result.slotsJson = slotsJson;
    }
    return $result;
  }
  SlotListResponse._() : super();
  factory SlotListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'slotsJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotListResponse clone() => SlotListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotListResponse copyWith(void Function(SlotListResponse) updates) => super.copyWith((message) => updates(message as SlotListResponse)) as SlotListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotListResponse create() => SlotListResponse._();
  SlotListResponse createEmptyInstance() => create();
  static $pb.PbList<SlotListResponse> createRepeated() => $pb.PbList<SlotListResponse>();
  @$core.pragma('dart2js:noInline')
  static SlotListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotListResponse>(create);
  static SlotListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlotsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotsJson() => clearField(1);
}

class SlotGetRequest extends $pb.GeneratedMessage {
  factory SlotGetRequest({
    $core.String? slotId,
  }) {
    final $result = create();
    if (slotId != null) {
      $result.slotId = slotId;
    }
    return $result;
  }
  SlotGetRequest._() : super();
  factory SlotGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'slotId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotGetRequest clone() => SlotGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotGetRequest copyWith(void Function(SlotGetRequest) updates) => super.copyWith((message) => updates(message as SlotGetRequest)) as SlotGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotGetRequest create() => SlotGetRequest._();
  SlotGetRequest createEmptyInstance() => create();
  static $pb.PbList<SlotGetRequest> createRepeated() => $pb.PbList<SlotGetRequest>();
  @$core.pragma('dart2js:noInline')
  static SlotGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotGetRequest>(create);
  static SlotGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotId => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlotId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotId() => clearField(1);
}

class SlotGetResponse extends $pb.GeneratedMessage {
  factory SlotGetResponse({
    $core.String? slotJson,
  }) {
    final $result = create();
    if (slotJson != null) {
      $result.slotJson = slotJson;
    }
    return $result;
  }
  SlotGetResponse._() : super();
  factory SlotGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'slotJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotGetResponse clone() => SlotGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotGetResponse copyWith(void Function(SlotGetResponse) updates) => super.copyWith((message) => updates(message as SlotGetResponse)) as SlotGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotGetResponse create() => SlotGetResponse._();
  SlotGetResponse createEmptyInstance() => create();
  static $pb.PbList<SlotGetResponse> createRepeated() => $pb.PbList<SlotGetResponse>();
  @$core.pragma('dart2js:noInline')
  static SlotGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotGetResponse>(create);
  static SlotGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlotJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotJson() => clearField(1);
}

class SlotClaimRequest extends $pb.GeneratedMessage {
  factory SlotClaimRequest({
    $fixnum.Int64? feeSats,
    $core.int? periodIndex,
    $core.int? slotIndex,
    $core.String? question,
    $core.bool? isStandard,
    $core.bool? isScaled,
    $core.int? min,
    $core.int? max,
  }) {
    final $result = create();
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (periodIndex != null) {
      $result.periodIndex = periodIndex;
    }
    if (slotIndex != null) {
      $result.slotIndex = slotIndex;
    }
    if (question != null) {
      $result.question = question;
    }
    if (isStandard != null) {
      $result.isStandard = isStandard;
    }
    if (isScaled != null) {
      $result.isScaled = isScaled;
    }
    if (min != null) {
      $result.min = min;
    }
    if (max != null) {
      $result.max = max;
    }
    return $result;
  }
  SlotClaimRequest._() : super();
  factory SlotClaimRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotClaimRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'periodIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'slotIndex', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'question')
    ..aOB(5, _omitFieldNames ? '' : 'isStandard')
    ..aOB(6, _omitFieldNames ? '' : 'isScaled')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'min', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'max', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotClaimRequest clone() => SlotClaimRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotClaimRequest copyWith(void Function(SlotClaimRequest) updates) => super.copyWith((message) => updates(message as SlotClaimRequest)) as SlotClaimRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotClaimRequest create() => SlotClaimRequest._();
  SlotClaimRequest createEmptyInstance() => create();
  static $pb.PbList<SlotClaimRequest> createRepeated() => $pb.PbList<SlotClaimRequest>();
  @$core.pragma('dart2js:noInline')
  static SlotClaimRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimRequest>(create);
  static SlotClaimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get periodIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set periodIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPeriodIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get slotIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set slotIndex($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSlotIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlotIndex() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get question => $_getSZ(3);
  @$pb.TagNumber(4)
  set question($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasQuestion() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuestion() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isStandard => $_getBF(4);
  @$pb.TagNumber(5)
  set isStandard($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsStandard() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsStandard() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isScaled => $_getBF(5);
  @$pb.TagNumber(6)
  set isScaled($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsScaled() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsScaled() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get min => $_getIZ(6);
  @$pb.TagNumber(7)
  set min($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMin() => $_has(6);
  @$pb.TagNumber(7)
  void clearMin() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get max => $_getIZ(7);
  @$pb.TagNumber(8)
  set max($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMax() => $_has(7);
  @$pb.TagNumber(8)
  void clearMax() => clearField(8);
}

class SlotClaimResponse extends $pb.GeneratedMessage {
  factory SlotClaimResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SlotClaimResponse._() : super();
  factory SlotClaimResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotClaimResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotClaimResponse clone() => SlotClaimResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotClaimResponse copyWith(void Function(SlotClaimResponse) updates) => super.copyWith((message) => updates(message as SlotClaimResponse)) as SlotClaimResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotClaimResponse create() => SlotClaimResponse._();
  SlotClaimResponse createEmptyInstance() => create();
  static $pb.PbList<SlotClaimResponse> createRepeated() => $pb.PbList<SlotClaimResponse>();
  @$core.pragma('dart2js:noInline')
  static SlotClaimResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimResponse>(create);
  static SlotClaimResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class SlotClaimCategoryRequest extends $pb.GeneratedMessage {
  factory SlotClaimCategoryRequest({
    $core.String? slotsJson,
    $core.bool? isStandard,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (slotsJson != null) {
      $result.slotsJson = slotsJson;
    }
    if (isStandard != null) {
      $result.isStandard = isStandard;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  SlotClaimCategoryRequest._() : super();
  factory SlotClaimCategoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotClaimCategoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimCategoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'slotsJson')
    ..aOB(2, _omitFieldNames ? '' : 'isStandard')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotClaimCategoryRequest clone() => SlotClaimCategoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotClaimCategoryRequest copyWith(void Function(SlotClaimCategoryRequest) updates) => super.copyWith((message) => updates(message as SlotClaimCategoryRequest)) as SlotClaimCategoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryRequest create() => SlotClaimCategoryRequest._();
  SlotClaimCategoryRequest createEmptyInstance() => create();
  static $pb.PbList<SlotClaimCategoryRequest> createRepeated() => $pb.PbList<SlotClaimCategoryRequest>();
  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimCategoryRequest>(create);
  static SlotClaimCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotsJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlotsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotsJson() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isStandard => $_getBF(1);
  @$pb.TagNumber(2)
  set isStandard($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsStandard() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsStandard() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => clearField(3);
}

class SlotClaimCategoryResponse extends $pb.GeneratedMessage {
  factory SlotClaimCategoryResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SlotClaimCategoryResponse._() : super();
  factory SlotClaimCategoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SlotClaimCategoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimCategoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SlotClaimCategoryResponse clone() => SlotClaimCategoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SlotClaimCategoryResponse copyWith(void Function(SlotClaimCategoryResponse) updates) => super.copyWith((message) => updates(message as SlotClaimCategoryResponse)) as SlotClaimCategoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryResponse create() => SlotClaimCategoryResponse._();
  SlotClaimCategoryResponse createEmptyInstance() => create();
  static $pb.PbList<SlotClaimCategoryResponse> createRepeated() => $pb.PbList<SlotClaimCategoryResponse>();
  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimCategoryResponse>(create);
  static SlotClaimCategoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class VoteRegisterRequest extends $pb.GeneratedMessage {
  factory VoteRegisterRequest({
    $fixnum.Int64? feeSats,
    $fixnum.Int64? reputationBondSats,
  }) {
    final $result = create();
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (reputationBondSats != null) {
      $result.reputationBondSats = reputationBondSats;
    }
    return $result;
  }
  VoteRegisterRequest._() : super();
  factory VoteRegisterRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteRegisterRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteRegisterRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(2, _omitFieldNames ? '' : 'reputationBondSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteRegisterRequest clone() => VoteRegisterRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteRegisterRequest copyWith(void Function(VoteRegisterRequest) updates) => super.copyWith((message) => updates(message as VoteRegisterRequest)) as VoteRegisterRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteRegisterRequest create() => VoteRegisterRequest._();
  VoteRegisterRequest createEmptyInstance() => create();
  static $pb.PbList<VoteRegisterRequest> createRepeated() => $pb.PbList<VoteRegisterRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteRegisterRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteRegisterRequest>(create);
  static VoteRegisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get reputationBondSats => $_getI64(1);
  @$pb.TagNumber(2)
  set reputationBondSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReputationBondSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearReputationBondSats() => clearField(2);
}

class VoteRegisterResponse extends $pb.GeneratedMessage {
  factory VoteRegisterResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  VoteRegisterResponse._() : super();
  factory VoteRegisterResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteRegisterResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteRegisterResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteRegisterResponse clone() => VoteRegisterResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteRegisterResponse copyWith(void Function(VoteRegisterResponse) updates) => super.copyWith((message) => updates(message as VoteRegisterResponse)) as VoteRegisterResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteRegisterResponse create() => VoteRegisterResponse._();
  VoteRegisterResponse createEmptyInstance() => create();
  static $pb.PbList<VoteRegisterResponse> createRepeated() => $pb.PbList<VoteRegisterResponse>();
  @$core.pragma('dart2js:noInline')
  static VoteRegisterResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteRegisterResponse>(create);
  static VoteRegisterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class VoteVoterRequest extends $pb.GeneratedMessage {
  factory VoteVoterRequest({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  VoteVoterRequest._() : super();
  factory VoteVoterRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteVoterRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVoterRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteVoterRequest clone() => VoteVoterRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteVoterRequest copyWith(void Function(VoteVoterRequest) updates) => super.copyWith((message) => updates(message as VoteVoterRequest)) as VoteVoterRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteVoterRequest create() => VoteVoterRequest._();
  VoteVoterRequest createEmptyInstance() => create();
  static $pb.PbList<VoteVoterRequest> createRepeated() => $pb.PbList<VoteVoterRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteVoterRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVoterRequest>(create);
  static VoteVoterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class VoteVoterResponse extends $pb.GeneratedMessage {
  factory VoteVoterResponse({
    $core.String? voterJson,
  }) {
    final $result = create();
    if (voterJson != null) {
      $result.voterJson = voterJson;
    }
    return $result;
  }
  VoteVoterResponse._() : super();
  factory VoteVoterResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteVoterResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVoterResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'voterJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteVoterResponse clone() => VoteVoterResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteVoterResponse copyWith(void Function(VoteVoterResponse) updates) => super.copyWith((message) => updates(message as VoteVoterResponse)) as VoteVoterResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteVoterResponse create() => VoteVoterResponse._();
  VoteVoterResponse createEmptyInstance() => create();
  static $pb.PbList<VoteVoterResponse> createRepeated() => $pb.PbList<VoteVoterResponse>();
  @$core.pragma('dart2js:noInline')
  static VoteVoterResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVoterResponse>(create);
  static VoteVoterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get voterJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set voterJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVoterJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoterJson() => clearField(1);
}

class VoteVotersRequest extends $pb.GeneratedMessage {
  factory VoteVotersRequest() => create();
  VoteVotersRequest._() : super();
  factory VoteVotersRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteVotersRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVotersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteVotersRequest clone() => VoteVotersRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteVotersRequest copyWith(void Function(VoteVotersRequest) updates) => super.copyWith((message) => updates(message as VoteVotersRequest)) as VoteVotersRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteVotersRequest create() => VoteVotersRequest._();
  VoteVotersRequest createEmptyInstance() => create();
  static $pb.PbList<VoteVotersRequest> createRepeated() => $pb.PbList<VoteVotersRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteVotersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVotersRequest>(create);
  static VoteVotersRequest? _defaultInstance;
}

class VoteVotersResponse extends $pb.GeneratedMessage {
  factory VoteVotersResponse({
    $core.String? votersJson,
  }) {
    final $result = create();
    if (votersJson != null) {
      $result.votersJson = votersJson;
    }
    return $result;
  }
  VoteVotersResponse._() : super();
  factory VoteVotersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteVotersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVotersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'votersJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteVotersResponse clone() => VoteVotersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteVotersResponse copyWith(void Function(VoteVotersResponse) updates) => super.copyWith((message) => updates(message as VoteVotersResponse)) as VoteVotersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteVotersResponse create() => VoteVotersResponse._();
  VoteVotersResponse createEmptyInstance() => create();
  static $pb.PbList<VoteVotersResponse> createRepeated() => $pb.PbList<VoteVotersResponse>();
  @$core.pragma('dart2js:noInline')
  static VoteVotersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVotersResponse>(create);
  static VoteVotersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votersJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votersJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVotersJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotersJson() => clearField(1);
}

class VoteSubmitRequest extends $pb.GeneratedMessage {
  factory VoteSubmitRequest({
    $core.String? votesJson,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (votesJson != null) {
      $result.votesJson = votesJson;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  VoteSubmitRequest._() : super();
  factory VoteSubmitRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteSubmitRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteSubmitRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'votesJson')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteSubmitRequest clone() => VoteSubmitRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteSubmitRequest copyWith(void Function(VoteSubmitRequest) updates) => super.copyWith((message) => updates(message as VoteSubmitRequest)) as VoteSubmitRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteSubmitRequest create() => VoteSubmitRequest._();
  VoteSubmitRequest createEmptyInstance() => create();
  static $pb.PbList<VoteSubmitRequest> createRepeated() => $pb.PbList<VoteSubmitRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteSubmitRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteSubmitRequest>(create);
  static VoteSubmitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votesJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votesJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVotesJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotesJson() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);
}

class VoteSubmitResponse extends $pb.GeneratedMessage {
  factory VoteSubmitResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  VoteSubmitResponse._() : super();
  factory VoteSubmitResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteSubmitResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteSubmitResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteSubmitResponse clone() => VoteSubmitResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteSubmitResponse copyWith(void Function(VoteSubmitResponse) updates) => super.copyWith((message) => updates(message as VoteSubmitResponse)) as VoteSubmitResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteSubmitResponse create() => VoteSubmitResponse._();
  VoteSubmitResponse createEmptyInstance() => create();
  static $pb.PbList<VoteSubmitResponse> createRepeated() => $pb.PbList<VoteSubmitResponse>();
  @$core.pragma('dart2js:noInline')
  static VoteSubmitResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteSubmitResponse>(create);
  static VoteSubmitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class VoteListRequest extends $pb.GeneratedMessage {
  factory VoteListRequest({
    $core.String? voter,
    $core.String? decisionId,
    $core.int? periodId,
  }) {
    final $result = create();
    if (voter != null) {
      $result.voter = voter;
    }
    if (decisionId != null) {
      $result.decisionId = decisionId;
    }
    if (periodId != null) {
      $result.periodId = periodId;
    }
    return $result;
  }
  VoteListRequest._() : super();
  factory VoteListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'voter')
    ..aOS(2, _omitFieldNames ? '' : 'decisionId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'periodId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteListRequest clone() => VoteListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteListRequest copyWith(void Function(VoteListRequest) updates) => super.copyWith((message) => updates(message as VoteListRequest)) as VoteListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteListRequest create() => VoteListRequest._();
  VoteListRequest createEmptyInstance() => create();
  static $pb.PbList<VoteListRequest> createRepeated() => $pb.PbList<VoteListRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteListRequest>(create);
  static VoteListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get voter => $_getSZ(0);
  @$pb.TagNumber(1)
  set voter($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVoter() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoter() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get decisionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set decisionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDecisionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecisionId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get periodId => $_getIZ(2);
  @$pb.TagNumber(3)
  set periodId($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPeriodId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPeriodId() => clearField(3);
}

class VoteListResponse extends $pb.GeneratedMessage {
  factory VoteListResponse({
    $core.String? votesJson,
  }) {
    final $result = create();
    if (votesJson != null) {
      $result.votesJson = votesJson;
    }
    return $result;
  }
  VoteListResponse._() : super();
  factory VoteListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoteListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'votesJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoteListResponse clone() => VoteListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoteListResponse copyWith(void Function(VoteListResponse) updates) => super.copyWith((message) => updates(message as VoteListResponse)) as VoteListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteListResponse create() => VoteListResponse._();
  VoteListResponse createEmptyInstance() => create();
  static $pb.PbList<VoteListResponse> createRepeated() => $pb.PbList<VoteListResponse>();
  @$core.pragma('dart2js:noInline')
  static VoteListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteListResponse>(create);
  static VoteListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votesJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votesJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVotesJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotesJson() => clearField(1);
}

class VotePeriodRequest extends $pb.GeneratedMessage {
  factory VotePeriodRequest({
    $core.int? periodId,
  }) {
    final $result = create();
    if (periodId != null) {
      $result.periodId = periodId;
    }
    return $result;
  }
  VotePeriodRequest._() : super();
  factory VotePeriodRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotePeriodRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotePeriodRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'periodId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotePeriodRequest clone() => VotePeriodRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotePeriodRequest copyWith(void Function(VotePeriodRequest) updates) => super.copyWith((message) => updates(message as VotePeriodRequest)) as VotePeriodRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotePeriodRequest create() => VotePeriodRequest._();
  VotePeriodRequest createEmptyInstance() => create();
  static $pb.PbList<VotePeriodRequest> createRepeated() => $pb.PbList<VotePeriodRequest>();
  @$core.pragma('dart2js:noInline')
  static VotePeriodRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotePeriodRequest>(create);
  static VotePeriodRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get periodId => $_getIZ(0);
  @$pb.TagNumber(1)
  set periodId($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeriodId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriodId() => clearField(1);
}

class VotePeriodResponse extends $pb.GeneratedMessage {
  factory VotePeriodResponse({
    $core.String? periodJson,
  }) {
    final $result = create();
    if (periodJson != null) {
      $result.periodJson = periodJson;
    }
    return $result;
  }
  VotePeriodResponse._() : super();
  factory VotePeriodResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotePeriodResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotePeriodResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'periodJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotePeriodResponse clone() => VotePeriodResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotePeriodResponse copyWith(void Function(VotePeriodResponse) updates) => super.copyWith((message) => updates(message as VotePeriodResponse)) as VotePeriodResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotePeriodResponse create() => VotePeriodResponse._();
  VotePeriodResponse createEmptyInstance() => create();
  static $pb.PbList<VotePeriodResponse> createRepeated() => $pb.PbList<VotePeriodResponse>();
  @$core.pragma('dart2js:noInline')
  static VotePeriodResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotePeriodResponse>(create);
  static VotePeriodResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get periodJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set periodJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeriodJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriodJson() => clearField(1);
}

class VotecoinTransferRequest extends $pb.GeneratedMessage {
  factory VotecoinTransferRequest({
    $core.String? dest,
    $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
    $core.String? memo,
  }) {
    final $result = create();
    if (dest != null) {
      $result.dest = dest;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (memo != null) {
      $result.memo = memo;
    }
    return $result;
  }
  VotecoinTransferRequest._() : super();
  factory VotecoinTransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotecoinTransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinTransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dest')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotecoinTransferRequest clone() => VotecoinTransferRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotecoinTransferRequest copyWith(void Function(VotecoinTransferRequest) updates) => super.copyWith((message) => updates(message as VotecoinTransferRequest)) as VotecoinTransferRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotecoinTransferRequest create() => VotecoinTransferRequest._();
  VotecoinTransferRequest createEmptyInstance() => create();
  static $pb.PbList<VotecoinTransferRequest> createRepeated() => $pb.PbList<VotecoinTransferRequest>();
  @$core.pragma('dart2js:noInline')
  static VotecoinTransferRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotecoinTransferRequest>(create);
  static VotecoinTransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dest => $_getSZ(0);
  @$pb.TagNumber(1)
  set dest($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDest() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

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

class VotecoinTransferResponse extends $pb.GeneratedMessage {
  factory VotecoinTransferResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  VotecoinTransferResponse._() : super();
  factory VotecoinTransferResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotecoinTransferResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinTransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotecoinTransferResponse clone() => VotecoinTransferResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotecoinTransferResponse copyWith(void Function(VotecoinTransferResponse) updates) => super.copyWith((message) => updates(message as VotecoinTransferResponse)) as VotecoinTransferResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotecoinTransferResponse create() => VotecoinTransferResponse._();
  VotecoinTransferResponse createEmptyInstance() => create();
  static $pb.PbList<VotecoinTransferResponse> createRepeated() => $pb.PbList<VotecoinTransferResponse>();
  @$core.pragma('dart2js:noInline')
  static VotecoinTransferResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotecoinTransferResponse>(create);
  static VotecoinTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class VotecoinBalanceRequest extends $pb.GeneratedMessage {
  factory VotecoinBalanceRequest({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  VotecoinBalanceRequest._() : super();
  factory VotecoinBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotecoinBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotecoinBalanceRequest clone() => VotecoinBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotecoinBalanceRequest copyWith(void Function(VotecoinBalanceRequest) updates) => super.copyWith((message) => updates(message as VotecoinBalanceRequest)) as VotecoinBalanceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceRequest create() => VotecoinBalanceRequest._();
  VotecoinBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<VotecoinBalanceRequest> createRepeated() => $pb.PbList<VotecoinBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotecoinBalanceRequest>(create);
  static VotecoinBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class VotecoinBalanceResponse extends $pb.GeneratedMessage {
  factory VotecoinBalanceResponse({
    $fixnum.Int64? balance,
  }) {
    final $result = create();
    if (balance != null) {
      $result.balance = balance;
    }
    return $result;
  }
  VotecoinBalanceResponse._() : super();
  factory VotecoinBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VotecoinBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'balance')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VotecoinBalanceResponse clone() => VotecoinBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VotecoinBalanceResponse copyWith(void Function(VotecoinBalanceResponse) updates) => super.copyWith((message) => updates(message as VotecoinBalanceResponse)) as VotecoinBalanceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceResponse create() => VotecoinBalanceResponse._();
  VotecoinBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<VotecoinBalanceResponse> createRepeated() => $pb.PbList<VotecoinBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotecoinBalanceResponse>(create);
  static VotecoinBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get balance => $_getI64(0);
  @$pb.TagNumber(1)
  set balance($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBalance() => $_has(0);
  @$pb.TagNumber(1)
  void clearBalance() => clearField(1);
}

class TransferVotecoinRequest extends $pb.GeneratedMessage {
  factory TransferVotecoinRequest({
    $core.String? dest,
    $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
    $core.String? memo,
  }) {
    final $result = create();
    if (dest != null) {
      $result.dest = dest;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (memo != null) {
      $result.memo = memo;
    }
    return $result;
  }
  TransferVotecoinRequest._() : super();
  factory TransferVotecoinRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferVotecoinRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferVotecoinRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dest')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferVotecoinRequest clone() => TransferVotecoinRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferVotecoinRequest copyWith(void Function(TransferVotecoinRequest) updates) => super.copyWith((message) => updates(message as TransferVotecoinRequest)) as TransferVotecoinRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferVotecoinRequest create() => TransferVotecoinRequest._();
  TransferVotecoinRequest createEmptyInstance() => create();
  static $pb.PbList<TransferVotecoinRequest> createRepeated() => $pb.PbList<TransferVotecoinRequest>();
  @$core.pragma('dart2js:noInline')
  static TransferVotecoinRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferVotecoinRequest>(create);
  static TransferVotecoinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dest => $_getSZ(0);
  @$pb.TagNumber(1)
  set dest($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDest() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

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

class TransferVotecoinResponse extends $pb.GeneratedMessage {
  factory TransferVotecoinResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TransferVotecoinResponse._() : super();
  factory TransferVotecoinResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferVotecoinResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferVotecoinResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferVotecoinResponse clone() => TransferVotecoinResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferVotecoinResponse copyWith(void Function(TransferVotecoinResponse) updates) => super.copyWith((message) => updates(message as TransferVotecoinResponse)) as TransferVotecoinResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferVotecoinResponse create() => TransferVotecoinResponse._();
  TransferVotecoinResponse createEmptyInstance() => create();
  static $pb.PbList<TransferVotecoinResponse> createRepeated() => $pb.PbList<TransferVotecoinResponse>();
  @$core.pragma('dart2js:noInline')
  static TransferVotecoinResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferVotecoinResponse>(create);
  static TransferVotecoinResponse? _defaultInstance;

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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
    $core.String? dst,
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
    if (dst != null) {
      $result.dst = dst;
    }
    return $result;
  }
  VerifySignatureRequest._() : super();
  factory VerifySignatureRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifySignatureRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..aOS(3, _omitFieldNames ? '' : 'verifyingKey')
    ..aOS(4, _omitFieldNames ? '' : 'dst')
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

  @$pb.TagNumber(4)
  $core.String get dst => $_getSZ(3);
  @$pb.TagNumber(4)
  set dst($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDst() => $_has(3);
  @$pb.TagNumber(4)
  void clearDst() => clearField(4);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'), createEmptyInstance: create)
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

class TruthcoinServiceApi {
  $pb.RpcClient _client;
  TruthcoinServiceApi(this._client);

  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'TruthcoinService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
    _client.invoke<GetBlockCountResponse>(ctx, 'TruthcoinService', 'GetBlockCount', request, GetBlockCountResponse())
  ;
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
    _client.invoke<StopResponse>(ctx, 'TruthcoinService', 'Stop', request, StopResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'TruthcoinService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
    _client.invoke<WithdrawResponse>(ctx, 'TruthcoinService', 'Withdraw', request, WithdrawResponse())
  ;
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
    _client.invoke<TransferResponse>(ctx, 'TruthcoinService', 'Transfer', request, TransferResponse())
  ;
  $async.Future<GetSidechainWealthResponse> getSidechainWealth($pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
    _client.invoke<GetSidechainWealthResponse>(ctx, 'TruthcoinService', 'GetSidechainWealth', request, GetSidechainWealthResponse())
  ;
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
    _client.invoke<CreateDepositResponse>(ctx, 'TruthcoinService', 'CreateDeposit', request, CreateDepositResponse())
  ;
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
    _client.invoke<GetPendingWithdrawalBundleResponse>(ctx, 'TruthcoinService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse())
  ;
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
    _client.invoke<ConnectPeerResponse>(ctx, 'TruthcoinService', 'ConnectPeer', request, ConnectPeerResponse())
  ;
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
    _client.invoke<ListPeersResponse>(ctx, 'TruthcoinService', 'ListPeers', request, ListPeersResponse())
  ;
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
    _client.invoke<MineResponse>(ctx, 'TruthcoinService', 'Mine', request, MineResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'TruthcoinService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
    _client.invoke<GetBestMainchainBlockHashResponse>(ctx, 'TruthcoinService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse())
  ;
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
    _client.invoke<GetBestSidechainBlockHashResponse>(ctx, 'TruthcoinService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse())
  ;
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
    _client.invoke<GetBmmInclusionsResponse>(ctx, 'TruthcoinService', 'GetBmmInclusions', request, GetBmmInclusionsResponse())
  ;
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) =>
    _client.invoke<GetWalletUtxosResponse>(ctx, 'TruthcoinService', 'GetWalletUtxos', request, GetWalletUtxosResponse())
  ;
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
    _client.invoke<ListUtxosResponse>(ctx, 'TruthcoinService', 'ListUtxos', request, ListUtxosResponse())
  ;
  $async.Future<RemoveFromMempoolResponse> removeFromMempool($pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
    _client.invoke<RemoveFromMempoolResponse>(ctx, 'TruthcoinService', 'RemoveFromMempool', request, RemoveFromMempoolResponse())
  ;
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
    _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'TruthcoinService', 'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse())
  ;
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
    _client.invoke<GenerateMnemonicResponse>(ctx, 'TruthcoinService', 'GenerateMnemonic', request, GenerateMnemonicResponse())
  ;
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
    _client.invoke<SetSeedFromMnemonicResponse>(ctx, 'TruthcoinService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse())
  ;
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
    _client.invoke<CallRawResponse>(ctx, 'TruthcoinService', 'CallRaw', request, CallRawResponse())
  ;
  $async.Future<RefreshWalletResponse> refreshWallet($pb.ClientContext? ctx, RefreshWalletRequest request) =>
    _client.invoke<RefreshWalletResponse>(ctx, 'TruthcoinService', 'RefreshWallet', request, RefreshWalletResponse())
  ;
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
    _client.invoke<GetTransactionResponse>(ctx, 'TruthcoinService', 'GetTransaction', request, GetTransactionResponse())
  ;
  $async.Future<GetTransactionInfoResponse> getTransactionInfo($pb.ClientContext? ctx, GetTransactionInfoRequest request) =>
    _client.invoke<GetTransactionInfoResponse>(ctx, 'TruthcoinService', 'GetTransactionInfo', request, GetTransactionInfoResponse())
  ;
  $async.Future<GetWalletAddressesResponse> getWalletAddresses($pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
    _client.invoke<GetWalletAddressesResponse>(ctx, 'TruthcoinService', 'GetWalletAddresses', request, GetWalletAddressesResponse())
  ;
  $async.Future<MyUtxosResponse> myUtxos($pb.ClientContext? ctx, MyUtxosRequest request) =>
    _client.invoke<MyUtxosResponse>(ctx, 'TruthcoinService', 'MyUtxos', request, MyUtxosResponse())
  ;
  $async.Future<MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ClientContext? ctx, MyUnconfirmedUtxosRequest request) =>
    _client.invoke<MyUnconfirmedUtxosResponse>(ctx, 'TruthcoinService', 'MyUnconfirmedUtxos', request, MyUnconfirmedUtxosResponse())
  ;
  $async.Future<CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ClientContext? ctx, CalculateInitialLiquidityRequest request) =>
    _client.invoke<CalculateInitialLiquidityResponse>(ctx, 'TruthcoinService', 'CalculateInitialLiquidity', request, CalculateInitialLiquidityResponse())
  ;
  $async.Future<MarketCreateResponse> marketCreate($pb.ClientContext? ctx, MarketCreateRequest request) =>
    _client.invoke<MarketCreateResponse>(ctx, 'TruthcoinService', 'MarketCreate', request, MarketCreateResponse())
  ;
  $async.Future<MarketListResponse> marketList($pb.ClientContext? ctx, MarketListRequest request) =>
    _client.invoke<MarketListResponse>(ctx, 'TruthcoinService', 'MarketList', request, MarketListResponse())
  ;
  $async.Future<MarketGetResponse> marketGet($pb.ClientContext? ctx, MarketGetRequest request) =>
    _client.invoke<MarketGetResponse>(ctx, 'TruthcoinService', 'MarketGet', request, MarketGetResponse())
  ;
  $async.Future<MarketBuyResponse> marketBuy($pb.ClientContext? ctx, MarketBuyRequest request) =>
    _client.invoke<MarketBuyResponse>(ctx, 'TruthcoinService', 'MarketBuy', request, MarketBuyResponse())
  ;
  $async.Future<MarketSellResponse> marketSell($pb.ClientContext? ctx, MarketSellRequest request) =>
    _client.invoke<MarketSellResponse>(ctx, 'TruthcoinService', 'MarketSell', request, MarketSellResponse())
  ;
  $async.Future<MarketPositionsResponse> marketPositions($pb.ClientContext? ctx, MarketPositionsRequest request) =>
    _client.invoke<MarketPositionsResponse>(ctx, 'TruthcoinService', 'MarketPositions', request, MarketPositionsResponse())
  ;
  $async.Future<SlotStatusResponse> slotStatus($pb.ClientContext? ctx, SlotStatusRequest request) =>
    _client.invoke<SlotStatusResponse>(ctx, 'TruthcoinService', 'SlotStatus', request, SlotStatusResponse())
  ;
  $async.Future<SlotListResponse> slotList($pb.ClientContext? ctx, SlotListRequest request) =>
    _client.invoke<SlotListResponse>(ctx, 'TruthcoinService', 'SlotList', request, SlotListResponse())
  ;
  $async.Future<SlotGetResponse> slotGet($pb.ClientContext? ctx, SlotGetRequest request) =>
    _client.invoke<SlotGetResponse>(ctx, 'TruthcoinService', 'SlotGet', request, SlotGetResponse())
  ;
  $async.Future<SlotClaimResponse> slotClaim($pb.ClientContext? ctx, SlotClaimRequest request) =>
    _client.invoke<SlotClaimResponse>(ctx, 'TruthcoinService', 'SlotClaim', request, SlotClaimResponse())
  ;
  $async.Future<SlotClaimCategoryResponse> slotClaimCategory($pb.ClientContext? ctx, SlotClaimCategoryRequest request) =>
    _client.invoke<SlotClaimCategoryResponse>(ctx, 'TruthcoinService', 'SlotClaimCategory', request, SlotClaimCategoryResponse())
  ;
  $async.Future<VoteRegisterResponse> voteRegister($pb.ClientContext? ctx, VoteRegisterRequest request) =>
    _client.invoke<VoteRegisterResponse>(ctx, 'TruthcoinService', 'VoteRegister', request, VoteRegisterResponse())
  ;
  $async.Future<VoteVoterResponse> voteVoter($pb.ClientContext? ctx, VoteVoterRequest request) =>
    _client.invoke<VoteVoterResponse>(ctx, 'TruthcoinService', 'VoteVoter', request, VoteVoterResponse())
  ;
  $async.Future<VoteVotersResponse> voteVoters($pb.ClientContext? ctx, VoteVotersRequest request) =>
    _client.invoke<VoteVotersResponse>(ctx, 'TruthcoinService', 'VoteVoters', request, VoteVotersResponse())
  ;
  $async.Future<VoteSubmitResponse> voteSubmit($pb.ClientContext? ctx, VoteSubmitRequest request) =>
    _client.invoke<VoteSubmitResponse>(ctx, 'TruthcoinService', 'VoteSubmit', request, VoteSubmitResponse())
  ;
  $async.Future<VoteListResponse> voteList($pb.ClientContext? ctx, VoteListRequest request) =>
    _client.invoke<VoteListResponse>(ctx, 'TruthcoinService', 'VoteList', request, VoteListResponse())
  ;
  $async.Future<VotePeriodResponse> votePeriod($pb.ClientContext? ctx, VotePeriodRequest request) =>
    _client.invoke<VotePeriodResponse>(ctx, 'TruthcoinService', 'VotePeriod', request, VotePeriodResponse())
  ;
  $async.Future<VotecoinTransferResponse> votecoinTransfer($pb.ClientContext? ctx, VotecoinTransferRequest request) =>
    _client.invoke<VotecoinTransferResponse>(ctx, 'TruthcoinService', 'VotecoinTransfer', request, VotecoinTransferResponse())
  ;
  $async.Future<VotecoinBalanceResponse> votecoinBalance($pb.ClientContext? ctx, VotecoinBalanceRequest request) =>
    _client.invoke<VotecoinBalanceResponse>(ctx, 'TruthcoinService', 'VotecoinBalance', request, VotecoinBalanceResponse())
  ;
  $async.Future<TransferVotecoinResponse> transferVotecoin($pb.ClientContext? ctx, TransferVotecoinRequest request) =>
    _client.invoke<TransferVotecoinResponse>(ctx, 'TruthcoinService', 'TransferVotecoin', request, TransferVotecoinResponse())
  ;
  $async.Future<GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ClientContext? ctx, GetNewEncryptionKeyRequest request) =>
    _client.invoke<GetNewEncryptionKeyResponse>(ctx, 'TruthcoinService', 'GetNewEncryptionKey', request, GetNewEncryptionKeyResponse())
  ;
  $async.Future<GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ClientContext? ctx, GetNewVerifyingKeyRequest request) =>
    _client.invoke<GetNewVerifyingKeyResponse>(ctx, 'TruthcoinService', 'GetNewVerifyingKey', request, GetNewVerifyingKeyResponse())
  ;
  $async.Future<EncryptMsgResponse> encryptMsg($pb.ClientContext? ctx, EncryptMsgRequest request) =>
    _client.invoke<EncryptMsgResponse>(ctx, 'TruthcoinService', 'EncryptMsg', request, EncryptMsgResponse())
  ;
  $async.Future<DecryptMsgResponse> decryptMsg($pb.ClientContext? ctx, DecryptMsgRequest request) =>
    _client.invoke<DecryptMsgResponse>(ctx, 'TruthcoinService', 'DecryptMsg', request, DecryptMsgResponse())
  ;
  $async.Future<SignArbitraryMsgResponse> signArbitraryMsg($pb.ClientContext? ctx, SignArbitraryMsgRequest request) =>
    _client.invoke<SignArbitraryMsgResponse>(ctx, 'TruthcoinService', 'SignArbitraryMsg', request, SignArbitraryMsgResponse())
  ;
  $async.Future<SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ClientContext? ctx, SignArbitraryMsgAsAddrRequest request) =>
    _client.invoke<SignArbitraryMsgAsAddrResponse>(ctx, 'TruthcoinService', 'SignArbitraryMsgAsAddr', request, SignArbitraryMsgAsAddrResponse())
  ;
  $async.Future<VerifySignatureResponse> verifySignature($pb.ClientContext? ctx, VerifySignatureRequest request) =>
    _client.invoke<VerifySignatureResponse>(ctx, 'TruthcoinService', 'VerifySignature', request, VerifySignatureResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
