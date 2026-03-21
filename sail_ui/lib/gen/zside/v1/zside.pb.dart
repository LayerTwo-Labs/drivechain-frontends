//
//  Generated code. Do not modify.
//  source: zside/v1/zside.proto
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

class GetBalanceBreakdownRequest extends $pb.GeneratedMessage {
  factory GetBalanceBreakdownRequest() => create();
  GetBalanceBreakdownRequest._() : super();
  factory GetBalanceBreakdownRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceBreakdownRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceBreakdownRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceBreakdownRequest clone() => GetBalanceBreakdownRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceBreakdownRequest copyWith(void Function(GetBalanceBreakdownRequest) updates) => super.copyWith((message) => updates(message as GetBalanceBreakdownRequest)) as GetBalanceBreakdownRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceBreakdownRequest create() => GetBalanceBreakdownRequest._();
  GetBalanceBreakdownRequest createEmptyInstance() => create();
  static $pb.PbList<GetBalanceBreakdownRequest> createRepeated() => $pb.PbList<GetBalanceBreakdownRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceBreakdownRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceBreakdownRequest>(create);
  static GetBalanceBreakdownRequest? _defaultInstance;
}

class GetBalanceBreakdownResponse extends $pb.GeneratedMessage {
  factory GetBalanceBreakdownResponse({
    $fixnum.Int64? availableShieldedSats,
    $fixnum.Int64? availableTransparentSats,
    $fixnum.Int64? totalShieldedSats,
    $fixnum.Int64? totalTransparentSats,
  }) {
    final $result = create();
    if (availableShieldedSats != null) {
      $result.availableShieldedSats = availableShieldedSats;
    }
    if (availableTransparentSats != null) {
      $result.availableTransparentSats = availableTransparentSats;
    }
    if (totalShieldedSats != null) {
      $result.totalShieldedSats = totalShieldedSats;
    }
    if (totalTransparentSats != null) {
      $result.totalTransparentSats = totalTransparentSats;
    }
    return $result;
  }
  GetBalanceBreakdownResponse._() : super();
  factory GetBalanceBreakdownResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceBreakdownResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceBreakdownResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'availableShieldedSats')
    ..aInt64(2, _omitFieldNames ? '' : 'availableTransparentSats')
    ..aInt64(3, _omitFieldNames ? '' : 'totalShieldedSats')
    ..aInt64(4, _omitFieldNames ? '' : 'totalTransparentSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceBreakdownResponse clone() => GetBalanceBreakdownResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceBreakdownResponse copyWith(void Function(GetBalanceBreakdownResponse) updates) => super.copyWith((message) => updates(message as GetBalanceBreakdownResponse)) as GetBalanceBreakdownResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceBreakdownResponse create() => GetBalanceBreakdownResponse._();
  GetBalanceBreakdownResponse createEmptyInstance() => create();
  static $pb.PbList<GetBalanceBreakdownResponse> createRepeated() => $pb.PbList<GetBalanceBreakdownResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceBreakdownResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceBreakdownResponse>(create);
  static GetBalanceBreakdownResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get availableShieldedSats => $_getI64(0);
  @$pb.TagNumber(1)
  set availableShieldedSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAvailableShieldedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearAvailableShieldedSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get availableTransparentSats => $_getI64(1);
  @$pb.TagNumber(2)
  set availableTransparentSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvailableTransparentSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableTransparentSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalShieldedSats => $_getI64(2);
  @$pb.TagNumber(3)
  set totalShieldedSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalShieldedSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalShieldedSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalTransparentSats => $_getI64(3);
  @$pb.TagNumber(4)
  set totalTransparentSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalTransparentSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalTransparentSats() => clearField(4);
}

class GetBlockCountRequest extends $pb.GeneratedMessage {
  factory GetBlockCountRequest() => create();
  GetBlockCountRequest._() : super();
  factory GetBlockCountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockCountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

class GetNewTransparentAddressRequest extends $pb.GeneratedMessage {
  factory GetNewTransparentAddressRequest() => create();
  GetNewTransparentAddressRequest._() : super();
  factory GetNewTransparentAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewTransparentAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewTransparentAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewTransparentAddressRequest clone() => GetNewTransparentAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewTransparentAddressRequest copyWith(void Function(GetNewTransparentAddressRequest) updates) => super.copyWith((message) => updates(message as GetNewTransparentAddressRequest)) as GetNewTransparentAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewTransparentAddressRequest create() => GetNewTransparentAddressRequest._();
  GetNewTransparentAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewTransparentAddressRequest> createRepeated() => $pb.PbList<GetNewTransparentAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewTransparentAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewTransparentAddressRequest>(create);
  static GetNewTransparentAddressRequest? _defaultInstance;
}

class GetNewTransparentAddressResponse extends $pb.GeneratedMessage {
  factory GetNewTransparentAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetNewTransparentAddressResponse._() : super();
  factory GetNewTransparentAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewTransparentAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewTransparentAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewTransparentAddressResponse clone() => GetNewTransparentAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewTransparentAddressResponse copyWith(void Function(GetNewTransparentAddressResponse) updates) => super.copyWith((message) => updates(message as GetNewTransparentAddressResponse)) as GetNewTransparentAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewTransparentAddressResponse create() => GetNewTransparentAddressResponse._();
  GetNewTransparentAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewTransparentAddressResponse> createRepeated() => $pb.PbList<GetNewTransparentAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewTransparentAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewTransparentAddressResponse>(create);
  static GetNewTransparentAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class GetNewShieldedAddressRequest extends $pb.GeneratedMessage {
  factory GetNewShieldedAddressRequest() => create();
  GetNewShieldedAddressRequest._() : super();
  factory GetNewShieldedAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewShieldedAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewShieldedAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewShieldedAddressRequest clone() => GetNewShieldedAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewShieldedAddressRequest copyWith(void Function(GetNewShieldedAddressRequest) updates) => super.copyWith((message) => updates(message as GetNewShieldedAddressRequest)) as GetNewShieldedAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewShieldedAddressRequest create() => GetNewShieldedAddressRequest._();
  GetNewShieldedAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewShieldedAddressRequest> createRepeated() => $pb.PbList<GetNewShieldedAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewShieldedAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewShieldedAddressRequest>(create);
  static GetNewShieldedAddressRequest? _defaultInstance;
}

class GetNewShieldedAddressResponse extends $pb.GeneratedMessage {
  factory GetNewShieldedAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetNewShieldedAddressResponse._() : super();
  factory GetNewShieldedAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewShieldedAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewShieldedAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewShieldedAddressResponse clone() => GetNewShieldedAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewShieldedAddressResponse copyWith(void Function(GetNewShieldedAddressResponse) updates) => super.copyWith((message) => updates(message as GetNewShieldedAddressResponse)) as GetNewShieldedAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewShieldedAddressResponse create() => GetNewShieldedAddressResponse._();
  GetNewShieldedAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewShieldedAddressResponse> createRepeated() => $pb.PbList<GetNewShieldedAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewShieldedAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewShieldedAddressResponse>(create);
  static GetNewShieldedAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class GetShieldedWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetShieldedWalletAddressesRequest() => create();
  GetShieldedWalletAddressesRequest._() : super();
  factory GetShieldedWalletAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetShieldedWalletAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetShieldedWalletAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetShieldedWalletAddressesRequest clone() => GetShieldedWalletAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetShieldedWalletAddressesRequest copyWith(void Function(GetShieldedWalletAddressesRequest) updates) => super.copyWith((message) => updates(message as GetShieldedWalletAddressesRequest)) as GetShieldedWalletAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetShieldedWalletAddressesRequest create() => GetShieldedWalletAddressesRequest._();
  GetShieldedWalletAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<GetShieldedWalletAddressesRequest> createRepeated() => $pb.PbList<GetShieldedWalletAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetShieldedWalletAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShieldedWalletAddressesRequest>(create);
  static GetShieldedWalletAddressesRequest? _defaultInstance;
}

class GetShieldedWalletAddressesResponse extends $pb.GeneratedMessage {
  factory GetShieldedWalletAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  GetShieldedWalletAddressesResponse._() : super();
  factory GetShieldedWalletAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetShieldedWalletAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetShieldedWalletAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetShieldedWalletAddressesResponse clone() => GetShieldedWalletAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetShieldedWalletAddressesResponse copyWith(void Function(GetShieldedWalletAddressesResponse) updates) => super.copyWith((message) => updates(message as GetShieldedWalletAddressesResponse)) as GetShieldedWalletAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetShieldedWalletAddressesResponse create() => GetShieldedWalletAddressesResponse._();
  GetShieldedWalletAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<GetShieldedWalletAddressesResponse> createRepeated() => $pb.PbList<GetShieldedWalletAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetShieldedWalletAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetShieldedWalletAddressesResponse>(create);
  static GetShieldedWalletAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
}

class GetTransparentWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetTransparentWalletAddressesRequest() => create();
  GetTransparentWalletAddressesRequest._() : super();
  factory GetTransparentWalletAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransparentWalletAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransparentWalletAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransparentWalletAddressesRequest clone() => GetTransparentWalletAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransparentWalletAddressesRequest copyWith(void Function(GetTransparentWalletAddressesRequest) updates) => super.copyWith((message) => updates(message as GetTransparentWalletAddressesRequest)) as GetTransparentWalletAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransparentWalletAddressesRequest create() => GetTransparentWalletAddressesRequest._();
  GetTransparentWalletAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransparentWalletAddressesRequest> createRepeated() => $pb.PbList<GetTransparentWalletAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransparentWalletAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransparentWalletAddressesRequest>(create);
  static GetTransparentWalletAddressesRequest? _defaultInstance;
}

class GetTransparentWalletAddressesResponse extends $pb.GeneratedMessage {
  factory GetTransparentWalletAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  GetTransparentWalletAddressesResponse._() : super();
  factory GetTransparentWalletAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransparentWalletAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransparentWalletAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransparentWalletAddressesResponse clone() => GetTransparentWalletAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransparentWalletAddressesResponse copyWith(void Function(GetTransparentWalletAddressesResponse) updates) => super.copyWith((message) => updates(message as GetTransparentWalletAddressesResponse)) as GetTransparentWalletAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransparentWalletAddressesResponse create() => GetTransparentWalletAddressesResponse._();
  GetTransparentWalletAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransparentWalletAddressesResponse> createRepeated() => $pb.PbList<GetTransparentWalletAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransparentWalletAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransparentWalletAddressesResponse>(create);
  static GetTransparentWalletAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

class TransparentTransferRequest extends $pb.GeneratedMessage {
  factory TransparentTransferRequest({
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
  TransparentTransferRequest._() : super();
  factory TransparentTransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransparentTransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransparentTransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransparentTransferRequest clone() => TransparentTransferRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransparentTransferRequest copyWith(void Function(TransparentTransferRequest) updates) => super.copyWith((message) => updates(message as TransparentTransferRequest)) as TransparentTransferRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransparentTransferRequest create() => TransparentTransferRequest._();
  TransparentTransferRequest createEmptyInstance() => create();
  static $pb.PbList<TransparentTransferRequest> createRepeated() => $pb.PbList<TransparentTransferRequest>();
  @$core.pragma('dart2js:noInline')
  static TransparentTransferRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransparentTransferRequest>(create);
  static TransparentTransferRequest? _defaultInstance;

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

class TransparentTransferResponse extends $pb.GeneratedMessage {
  factory TransparentTransferResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TransparentTransferResponse._() : super();
  factory TransparentTransferResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransparentTransferResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransparentTransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransparentTransferResponse clone() => TransparentTransferResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransparentTransferResponse copyWith(void Function(TransparentTransferResponse) updates) => super.copyWith((message) => updates(message as TransparentTransferResponse)) as TransparentTransferResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransparentTransferResponse create() => TransparentTransferResponse._();
  TransparentTransferResponse createEmptyInstance() => create();
  static $pb.PbList<TransparentTransferResponse> createRepeated() => $pb.PbList<TransparentTransferResponse>();
  @$core.pragma('dart2js:noInline')
  static TransparentTransferResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransparentTransferResponse>(create);
  static TransparentTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ShieldedTransferRequest extends $pb.GeneratedMessage {
  factory ShieldedTransferRequest({
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
  ShieldedTransferRequest._() : super();
  factory ShieldedTransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShieldedTransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShieldedTransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShieldedTransferRequest clone() => ShieldedTransferRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShieldedTransferRequest copyWith(void Function(ShieldedTransferRequest) updates) => super.copyWith((message) => updates(message as ShieldedTransferRequest)) as ShieldedTransferRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShieldedTransferRequest create() => ShieldedTransferRequest._();
  ShieldedTransferRequest createEmptyInstance() => create();
  static $pb.PbList<ShieldedTransferRequest> createRepeated() => $pb.PbList<ShieldedTransferRequest>();
  @$core.pragma('dart2js:noInline')
  static ShieldedTransferRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShieldedTransferRequest>(create);
  static ShieldedTransferRequest? _defaultInstance;

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

class ShieldedTransferResponse extends $pb.GeneratedMessage {
  factory ShieldedTransferResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  ShieldedTransferResponse._() : super();
  factory ShieldedTransferResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShieldedTransferResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShieldedTransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShieldedTransferResponse clone() => ShieldedTransferResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShieldedTransferResponse copyWith(void Function(ShieldedTransferResponse) updates) => super.copyWith((message) => updates(message as ShieldedTransferResponse)) as ShieldedTransferResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShieldedTransferResponse create() => ShieldedTransferResponse._();
  ShieldedTransferResponse createEmptyInstance() => create();
  static $pb.PbList<ShieldedTransferResponse> createRepeated() => $pb.PbList<ShieldedTransferResponse>();
  @$core.pragma('dart2js:noInline')
  static ShieldedTransferResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShieldedTransferResponse>(create);
  static ShieldedTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ShieldRequest extends $pb.GeneratedMessage {
  factory ShieldRequest({
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  ShieldRequest._() : super();
  factory ShieldRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShieldRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShieldRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShieldRequest clone() => ShieldRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShieldRequest copyWith(void Function(ShieldRequest) updates) => super.copyWith((message) => updates(message as ShieldRequest)) as ShieldRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShieldRequest create() => ShieldRequest._();
  ShieldRequest createEmptyInstance() => create();
  static $pb.PbList<ShieldRequest> createRepeated() => $pb.PbList<ShieldRequest>();
  @$core.pragma('dart2js:noInline')
  static ShieldRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShieldRequest>(create);
  static ShieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountSats => $_getI64(0);
  @$pb.TagNumber(1)
  set amountSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmountSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);
}

class ShieldResponse extends $pb.GeneratedMessage {
  factory ShieldResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  ShieldResponse._() : super();
  factory ShieldResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShieldResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShieldResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShieldResponse clone() => ShieldResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShieldResponse copyWith(void Function(ShieldResponse) updates) => super.copyWith((message) => updates(message as ShieldResponse)) as ShieldResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShieldResponse create() => ShieldResponse._();
  ShieldResponse createEmptyInstance() => create();
  static $pb.PbList<ShieldResponse> createRepeated() => $pb.PbList<ShieldResponse>();
  @$core.pragma('dart2js:noInline')
  static ShieldResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShieldResponse>(create);
  static ShieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class UnshieldRequest extends $pb.GeneratedMessage {
  factory UnshieldRequest({
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  UnshieldRequest._() : super();
  factory UnshieldRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnshieldRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnshieldRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnshieldRequest clone() => UnshieldRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnshieldRequest copyWith(void Function(UnshieldRequest) updates) => super.copyWith((message) => updates(message as UnshieldRequest)) as UnshieldRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnshieldRequest create() => UnshieldRequest._();
  UnshieldRequest createEmptyInstance() => create();
  static $pb.PbList<UnshieldRequest> createRepeated() => $pb.PbList<UnshieldRequest>();
  @$core.pragma('dart2js:noInline')
  static UnshieldRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnshieldRequest>(create);
  static UnshieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountSats => $_getI64(0);
  @$pb.TagNumber(1)
  set amountSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmountSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);
}

class UnshieldResponse extends $pb.GeneratedMessage {
  factory UnshieldResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  UnshieldResponse._() : super();
  factory UnshieldResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnshieldResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnshieldResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnshieldResponse clone() => UnshieldResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnshieldResponse copyWith(void Function(UnshieldResponse) updates) => super.copyWith((message) => updates(message as UnshieldResponse)) as UnshieldResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnshieldResponse create() => UnshieldResponse._();
  UnshieldResponse createEmptyInstance() => create();
  static $pb.PbList<UnshieldResponse> createRepeated() => $pb.PbList<UnshieldResponse>();
  @$core.pragma('dart2js:noInline')
  static UnshieldResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnshieldResponse>(create);
  static UnshieldResponse? _defaultInstance;

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'zside.v1'), createEmptyInstance: create)
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

class ZSideServiceApi {
  $pb.RpcClient _client;
  ZSideServiceApi(this._client);

  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'ZSideService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetBalanceBreakdownResponse> getBalanceBreakdown($pb.ClientContext? ctx, GetBalanceBreakdownRequest request) =>
    _client.invoke<GetBalanceBreakdownResponse>(ctx, 'ZSideService', 'GetBalanceBreakdown', request, GetBalanceBreakdownResponse())
  ;
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
    _client.invoke<GetBlockCountResponse>(ctx, 'ZSideService', 'GetBlockCount', request, GetBlockCountResponse())
  ;
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
    _client.invoke<StopResponse>(ctx, 'ZSideService', 'Stop', request, StopResponse())
  ;
  $async.Future<GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ClientContext? ctx, GetNewTransparentAddressRequest request) =>
    _client.invoke<GetNewTransparentAddressResponse>(ctx, 'ZSideService', 'GetNewTransparentAddress', request, GetNewTransparentAddressResponse())
  ;
  $async.Future<GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ClientContext? ctx, GetNewShieldedAddressRequest request) =>
    _client.invoke<GetNewShieldedAddressResponse>(ctx, 'ZSideService', 'GetNewShieldedAddress', request, GetNewShieldedAddressResponse())
  ;
  $async.Future<GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ClientContext? ctx, GetShieldedWalletAddressesRequest request) =>
    _client.invoke<GetShieldedWalletAddressesResponse>(ctx, 'ZSideService', 'GetShieldedWalletAddresses', request, GetShieldedWalletAddressesResponse())
  ;
  $async.Future<GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ClientContext? ctx, GetTransparentWalletAddressesRequest request) =>
    _client.invoke<GetTransparentWalletAddressesResponse>(ctx, 'ZSideService', 'GetTransparentWalletAddresses', request, GetTransparentWalletAddressesResponse())
  ;
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
    _client.invoke<WithdrawResponse>(ctx, 'ZSideService', 'Withdraw', request, WithdrawResponse())
  ;
  $async.Future<TransparentTransferResponse> transparentTransfer($pb.ClientContext? ctx, TransparentTransferRequest request) =>
    _client.invoke<TransparentTransferResponse>(ctx, 'ZSideService', 'TransparentTransfer', request, TransparentTransferResponse())
  ;
  $async.Future<ShieldedTransferResponse> shieldedTransfer($pb.ClientContext? ctx, ShieldedTransferRequest request) =>
    _client.invoke<ShieldedTransferResponse>(ctx, 'ZSideService', 'ShieldedTransfer', request, ShieldedTransferResponse())
  ;
  $async.Future<ShieldResponse> shield($pb.ClientContext? ctx, ShieldRequest request) =>
    _client.invoke<ShieldResponse>(ctx, 'ZSideService', 'Shield', request, ShieldResponse())
  ;
  $async.Future<UnshieldResponse> unshield($pb.ClientContext? ctx, UnshieldRequest request) =>
    _client.invoke<UnshieldResponse>(ctx, 'ZSideService', 'Unshield', request, UnshieldResponse())
  ;
  $async.Future<GetSidechainWealthResponse> getSidechainWealth($pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
    _client.invoke<GetSidechainWealthResponse>(ctx, 'ZSideService', 'GetSidechainWealth', request, GetSidechainWealthResponse())
  ;
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
    _client.invoke<CreateDepositResponse>(ctx, 'ZSideService', 'CreateDeposit', request, CreateDepositResponse())
  ;
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
    _client.invoke<GetPendingWithdrawalBundleResponse>(ctx, 'ZSideService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse())
  ;
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
    _client.invoke<ConnectPeerResponse>(ctx, 'ZSideService', 'ConnectPeer', request, ConnectPeerResponse())
  ;
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
    _client.invoke<ListPeersResponse>(ctx, 'ZSideService', 'ListPeers', request, ListPeersResponse())
  ;
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
    _client.invoke<MineResponse>(ctx, 'ZSideService', 'Mine', request, MineResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'ZSideService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
    _client.invoke<GetBestMainchainBlockHashResponse>(ctx, 'ZSideService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse())
  ;
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
    _client.invoke<GetBestSidechainBlockHashResponse>(ctx, 'ZSideService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse())
  ;
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
    _client.invoke<GetBmmInclusionsResponse>(ctx, 'ZSideService', 'GetBmmInclusions', request, GetBmmInclusionsResponse())
  ;
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) =>
    _client.invoke<GetWalletUtxosResponse>(ctx, 'ZSideService', 'GetWalletUtxos', request, GetWalletUtxosResponse())
  ;
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
    _client.invoke<ListUtxosResponse>(ctx, 'ZSideService', 'ListUtxos', request, ListUtxosResponse())
  ;
  $async.Future<RemoveFromMempoolResponse> removeFromMempool($pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
    _client.invoke<RemoveFromMempoolResponse>(ctx, 'ZSideService', 'RemoveFromMempool', request, RemoveFromMempoolResponse())
  ;
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
    _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'ZSideService', 'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse())
  ;
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
    _client.invoke<GenerateMnemonicResponse>(ctx, 'ZSideService', 'GenerateMnemonic', request, GenerateMnemonicResponse())
  ;
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
    _client.invoke<SetSeedFromMnemonicResponse>(ctx, 'ZSideService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse())
  ;
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
    _client.invoke<CallRawResponse>(ctx, 'ZSideService', 'CallRaw', request, CallRawResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
