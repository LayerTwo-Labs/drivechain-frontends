// This is a generated file - do not edit.
//
// Generated from coinshift/v1/coinshift.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest() => GetBalanceRequest._();

  GetBalanceRequest._();

  factory GetBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromBuffer(data, registry);
  factory GetBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBalanceRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest copyWith(void Function(GetBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetBalanceRequest)) as GetBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalanceRequest() / GetBalanceRequest.new instead')
  static GetBalanceRequest create() => GetBalanceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBalanceRequest._();
  @$core.override
  GetBalanceRequest createEmptyInstance() => GetBalanceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceRequest>(GetBalanceRequest.$_createMessage);
  static GetBalanceRequest? _defaultInstance;
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $fixnum.Int64? totalSats,
    $fixnum.Int64? availableSats,
  }) {
    final result = GetBalanceResponse._();
    if (totalSats != null) result.totalSats = totalSats;
    if (availableSats != null) result.availableSats = availableSats;
    return result;
  }

  GetBalanceResponse._();

  factory GetBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceResponse()..mergeFromBuffer(data, registry);
  factory GetBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBalanceResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'totalSats')
    ..aInt64(2, _omitFieldNames ? '' : 'availableSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse copyWith(void Function(GetBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetBalanceResponse)) as GetBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalanceResponse() / GetBalanceResponse.new instead')
  static GetBalanceResponse create() => GetBalanceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBalanceResponse._();
  @$core.override
  GetBalanceResponse createEmptyInstance() => GetBalanceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceResponse>(GetBalanceResponse.$_createMessage);
  static GetBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalSats => $_getI64(0);
  @$pb.TagNumber(1)
  set totalSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get availableSats => $_getI64(1);
  @$pb.TagNumber(2)
  set availableSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvailableSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableSats() => $_clearField(2);
}

class GetBlockCountRequest extends $pb.GeneratedMessage {
  factory GetBlockCountRequest() => GetBlockCountRequest._();

  GetBlockCountRequest._();

  factory GetBlockCountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountRequest()..mergeFromBuffer(data, registry);
  factory GetBlockCountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBlockCountRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountRequest copyWith(void Function(GetBlockCountRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockCountRequest)) as GetBlockCountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockCountRequest() / GetBlockCountRequest.new instead')
  static GetBlockCountRequest create() => GetBlockCountRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockCountRequest._();
  @$core.override
  GetBlockCountRequest createEmptyInstance() => GetBlockCountRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockCountRequest>(GetBlockCountRequest.$_createMessage);
  static GetBlockCountRequest? _defaultInstance;
}

class GetBlockCountResponse extends $pb.GeneratedMessage {
  factory GetBlockCountResponse({
    $fixnum.Int64? count,
  }) {
    final result = GetBlockCountResponse._();
    if (count != null) result.count = count;
    return result;
  }

  GetBlockCountResponse._();

  factory GetBlockCountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountResponse()..mergeFromBuffer(data, registry);
  factory GetBlockCountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBlockCountResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountResponse copyWith(void Function(GetBlockCountResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockCountResponse)) as GetBlockCountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockCountResponse() / GetBlockCountResponse.new instead')
  static GetBlockCountResponse create() => GetBlockCountResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockCountResponse._();
  @$core.override
  GetBlockCountResponse createEmptyInstance() => GetBlockCountResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockCountResponse>(GetBlockCountResponse.$_createMessage);
  static GetBlockCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest() => StopRequest._();

  StopRequest._();

  factory StopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromBuffer(data, registry);
  factory StopRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: StopRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest copyWith(void Function(StopRequest) updates) =>
      super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopRequest() / StopRequest.new instead')
  static StopRequest create() => StopRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopRequest._();
  @$core.override
  StopRequest createEmptyInstance() => StopRequest._();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(StopRequest.$_createMessage);
  static StopRequest? _defaultInstance;
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => StopResponse._();

  StopResponse._();

  factory StopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromBuffer(data, registry);
  factory StopResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: StopResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse copyWith(void Function(StopResponse) updates) =>
      super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopResponse() / StopResponse.new instead')
  static StopResponse create() => StopResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopResponse._();
  @$core.override
  StopResponse createEmptyInstance() => StopResponse._();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(StopResponse.$_createMessage);
  static StopResponse? _defaultInstance;
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest() => GetNewAddressRequest._();

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetNewAddressRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressRequest() / GetNewAddressRequest.new instead')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressRequest._();
  @$core.override
  GetNewAddressRequest createEmptyInstance() => GetNewAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(GetNewAddressRequest.$_createMessage);
  static GetNewAddressRequest? _defaultInstance;
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
  }) {
    final result = GetNewAddressResponse._();
    if (address != null) result.address = address;
    return result;
  }

  GetNewAddressResponse._();

  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromBuffer(data, registry);
  factory GetNewAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetNewAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressResponse() / GetNewAddressResponse.new instead')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressResponse._();
  @$core.override
  GetNewAddressResponse createEmptyInstance() => GetNewAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(GetNewAddressResponse.$_createMessage);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class WithdrawRequest extends $pb.GeneratedMessage {
  factory WithdrawRequest({
    $core.String? address,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? sideFeeSats,
    $fixnum.Int64? mainFeeSats,
  }) {
    final result = WithdrawRequest._();
    if (address != null) result.address = address;
    if (amountSats != null) result.amountSats = amountSats;
    if (sideFeeSats != null) result.sideFeeSats = sideFeeSats;
    if (mainFeeSats != null) result.mainFeeSats = mainFeeSats;
    return result;
  }

  WithdrawRequest._();

  factory WithdrawRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawRequest()..mergeFromBuffer(data, registry);
  factory WithdrawRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: WithdrawRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'sideFeeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'mainFeeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawRequest copyWith(void Function(WithdrawRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawRequest)) as WithdrawRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawRequest() / WithdrawRequest.new instead')
  static WithdrawRequest create() => WithdrawRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawRequest._();
  @$core.override
  WithdrawRequest createEmptyInstance() => WithdrawRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawRequest>(WithdrawRequest.$_createMessage);
  static WithdrawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sideFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set sideFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSideFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearSideFeeSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get mainFeeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set mainFeeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMainFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearMainFeeSats() => $_clearField(4);
}

class WithdrawResponse extends $pb.GeneratedMessage {
  factory WithdrawResponse({
    $core.String? txid,
  }) {
    final result = WithdrawResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  WithdrawResponse._();

  factory WithdrawResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawResponse()..mergeFromBuffer(data, registry);
  factory WithdrawResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: WithdrawResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawResponse copyWith(void Function(WithdrawResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawResponse)) as WithdrawResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawResponse() / WithdrawResponse.new instead')
  static WithdrawResponse create() => WithdrawResponse._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawResponse._();
  @$core.override
  WithdrawResponse createEmptyInstance() => WithdrawResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawResponse>(WithdrawResponse.$_createMessage);
  static WithdrawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class TransferRequest extends $pb.GeneratedMessage {
  factory TransferRequest({
    $core.String? address,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSats,
  }) {
    final result = TransferRequest._();
    if (address != null) result.address = address;
    if (amountSats != null) result.amountSats = amountSats;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  TransferRequest._();

  factory TransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferRequest()..mergeFromBuffer(data, registry);
  factory TransferRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: TransferRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferRequest copyWith(void Function(TransferRequest) updates) =>
      super.copyWith((message) => updates(message as TransferRequest)) as TransferRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferRequest() / TransferRequest.new instead')
  static TransferRequest create() => TransferRequest._();
  static $pb.GeneratedMessage $_createMessage() => TransferRequest._();
  @$core.override
  TransferRequest createEmptyInstance() => TransferRequest._();
  @$core.pragma('dart2js:noInline')
  static TransferRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferRequest>(TransferRequest.$_createMessage);
  static TransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);
}

class TransferResponse extends $pb.GeneratedMessage {
  factory TransferResponse({
    $core.String? txid,
  }) {
    final result = TransferResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  TransferResponse._();

  factory TransferResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferResponse()..mergeFromBuffer(data, registry);
  factory TransferResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: TransferResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferResponse copyWith(void Function(TransferResponse) updates) =>
      super.copyWith((message) => updates(message as TransferResponse)) as TransferResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferResponse() / TransferResponse.new instead')
  static TransferResponse create() => TransferResponse._();
  static $pb.GeneratedMessage $_createMessage() => TransferResponse._();
  @$core.override
  TransferResponse createEmptyInstance() => TransferResponse._();
  @$core.pragma('dart2js:noInline')
  static TransferResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferResponse>(TransferResponse.$_createMessage);
  static TransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetSidechainWealthRequest extends $pb.GeneratedMessage {
  factory GetSidechainWealthRequest() => GetSidechainWealthRequest._();

  GetSidechainWealthRequest._();

  factory GetSidechainWealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainWealthRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainWealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainWealthRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetSidechainWealthRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainWealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainWealthRequest copyWith(void Function(GetSidechainWealthRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainWealthRequest)) as GetSidechainWealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainWealthRequest() / GetSidechainWealthRequest.new instead')
  static GetSidechainWealthRequest create() => GetSidechainWealthRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainWealthRequest._();
  @$core.override
  GetSidechainWealthRequest createEmptyInstance() => GetSidechainWealthRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainWealthRequest>(GetSidechainWealthRequest.$_createMessage);
  static GetSidechainWealthRequest? _defaultInstance;
}

class GetSidechainWealthResponse extends $pb.GeneratedMessage {
  factory GetSidechainWealthResponse({
    $fixnum.Int64? sats,
  }) {
    final result = GetSidechainWealthResponse._();
    if (sats != null) result.sats = sats;
    return result;
  }

  GetSidechainWealthResponse._();

  factory GetSidechainWealthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainWealthResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainWealthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainWealthResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainWealthResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetSidechainWealthResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'sats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainWealthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainWealthResponse copyWith(void Function(GetSidechainWealthResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainWealthResponse)) as GetSidechainWealthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainWealthResponse() / GetSidechainWealthResponse.new instead')
  static GetSidechainWealthResponse create() => GetSidechainWealthResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainWealthResponse._();
  @$core.override
  GetSidechainWealthResponse createEmptyInstance() => GetSidechainWealthResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainWealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainWealthResponse>(GetSidechainWealthResponse.$_createMessage);
  static GetSidechainWealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sats => $_getI64(0);
  @$pb.TagNumber(1)
  set sats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearSats() => $_clearField(1);
}

class CreateDepositRequest extends $pb.GeneratedMessage {
  factory CreateDepositRequest({
    $core.String? address,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? feeSats,
  }) {
    final result = CreateDepositRequest._();
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CreateDepositRequest._();

  factory CreateDepositRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositRequest()..mergeFromBuffer(data, registry);
  factory CreateDepositRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CreateDepositRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositRequest copyWith(void Function(CreateDepositRequest) updates) =>
      super.copyWith((message) => updates(message as CreateDepositRequest)) as CreateDepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateDepositRequest() / CreateDepositRequest.new instead')
  static CreateDepositRequest create() => CreateDepositRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateDepositRequest._();
  @$core.override
  CreateDepositRequest createEmptyInstance() => CreateDepositRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateDepositRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateDepositRequest>(CreateDepositRequest.$_createMessage);
  static CreateDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);
}

class CreateDepositResponse extends $pb.GeneratedMessage {
  factory CreateDepositResponse({
    $core.String? txid,
  }) {
    final result = CreateDepositResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateDepositResponse._();

  factory CreateDepositResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositResponse()..mergeFromBuffer(data, registry);
  factory CreateDepositResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CreateDepositResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositResponse copyWith(void Function(CreateDepositResponse) updates) =>
      super.copyWith((message) => updates(message as CreateDepositResponse)) as CreateDepositResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateDepositResponse() / CreateDepositResponse.new instead')
  static CreateDepositResponse create() => CreateDepositResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateDepositResponse._();
  @$core.override
  CreateDepositResponse createEmptyInstance() => CreateDepositResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateDepositResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateDepositResponse>(CreateDepositResponse.$_createMessage);
  static CreateDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetPendingWithdrawalBundleRequest extends $pb.GeneratedMessage {
  factory GetPendingWithdrawalBundleRequest() => GetPendingWithdrawalBundleRequest._();

  GetPendingWithdrawalBundleRequest._();

  factory GetPendingWithdrawalBundleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingWithdrawalBundleRequest()..mergeFromBuffer(data, registry);
  factory GetPendingWithdrawalBundleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingWithdrawalBundleRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetPendingWithdrawalBundleRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingWithdrawalBundleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingWithdrawalBundleRequest copyWith(void Function(GetPendingWithdrawalBundleRequest) updates) =>
      super.copyWith((message) => updates(message as GetPendingWithdrawalBundleRequest))
          as GetPendingWithdrawalBundleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingWithdrawalBundleRequest() / GetPendingWithdrawalBundleRequest.new instead')
  static GetPendingWithdrawalBundleRequest create() => GetPendingWithdrawalBundleRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingWithdrawalBundleRequest._();
  @$core.override
  GetPendingWithdrawalBundleRequest createEmptyInstance() => GetPendingWithdrawalBundleRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingWithdrawalBundleRequest>(
          GetPendingWithdrawalBundleRequest.$_createMessage);
  static GetPendingWithdrawalBundleRequest? _defaultInstance;
}

class GetPendingWithdrawalBundleResponse extends $pb.GeneratedMessage {
  factory GetPendingWithdrawalBundleResponse({
    $core.String? bundleJson,
  }) {
    final result = GetPendingWithdrawalBundleResponse._();
    if (bundleJson != null) result.bundleJson = bundleJson;
    return result;
  }

  GetPendingWithdrawalBundleResponse._();

  factory GetPendingWithdrawalBundleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingWithdrawalBundleResponse()..mergeFromBuffer(data, registry);
  factory GetPendingWithdrawalBundleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingWithdrawalBundleResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingWithdrawalBundleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetPendingWithdrawalBundleResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bundleJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingWithdrawalBundleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingWithdrawalBundleResponse copyWith(void Function(GetPendingWithdrawalBundleResponse) updates) =>
      super.copyWith((message) => updates(message as GetPendingWithdrawalBundleResponse))
          as GetPendingWithdrawalBundleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingWithdrawalBundleResponse() / GetPendingWithdrawalBundleResponse.new instead')
  static GetPendingWithdrawalBundleResponse create() => GetPendingWithdrawalBundleResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingWithdrawalBundleResponse._();
  @$core.override
  GetPendingWithdrawalBundleResponse createEmptyInstance() => GetPendingWithdrawalBundleResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPendingWithdrawalBundleResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingWithdrawalBundleResponse>(
          GetPendingWithdrawalBundleResponse.$_createMessage);
  static GetPendingWithdrawalBundleResponse? _defaultInstance;

  /// JSON string of the bundle, empty if none.
  @$pb.TagNumber(1)
  $core.String get bundleJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bundleJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBundleJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBundleJson() => $_clearField(1);
}

class ConnectPeerRequest extends $pb.GeneratedMessage {
  factory ConnectPeerRequest({
    $core.String? address,
  }) {
    final result = ConnectPeerRequest._();
    if (address != null) result.address = address;
    return result;
  }

  ConnectPeerRequest._();

  factory ConnectPeerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectPeerRequest()..mergeFromBuffer(data, registry);
  factory ConnectPeerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectPeerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ConnectPeerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectPeerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectPeerRequest copyWith(void Function(ConnectPeerRequest) updates) =>
      super.copyWith((message) => updates(message as ConnectPeerRequest)) as ConnectPeerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectPeerRequest() / ConnectPeerRequest.new instead')
  static ConnectPeerRequest create() => ConnectPeerRequest._();
  static $pb.GeneratedMessage $_createMessage() => ConnectPeerRequest._();
  @$core.override
  ConnectPeerRequest createEmptyInstance() => ConnectPeerRequest._();
  @$core.pragma('dart2js:noInline')
  static ConnectPeerRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectPeerRequest>(ConnectPeerRequest.$_createMessage);
  static ConnectPeerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class ConnectPeerResponse extends $pb.GeneratedMessage {
  factory ConnectPeerResponse() => ConnectPeerResponse._();

  ConnectPeerResponse._();

  factory ConnectPeerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectPeerResponse()..mergeFromBuffer(data, registry);
  factory ConnectPeerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectPeerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectPeerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ConnectPeerResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectPeerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectPeerResponse copyWith(void Function(ConnectPeerResponse) updates) =>
      super.copyWith((message) => updates(message as ConnectPeerResponse)) as ConnectPeerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectPeerResponse() / ConnectPeerResponse.new instead')
  static ConnectPeerResponse create() => ConnectPeerResponse._();
  static $pb.GeneratedMessage $_createMessage() => ConnectPeerResponse._();
  @$core.override
  ConnectPeerResponse createEmptyInstance() => ConnectPeerResponse._();
  @$core.pragma('dart2js:noInline')
  static ConnectPeerResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectPeerResponse>(ConnectPeerResponse.$_createMessage);
  static ConnectPeerResponse? _defaultInstance;
}

class ForgetPeerRequest extends $pb.GeneratedMessage {
  factory ForgetPeerRequest({
    $core.String? address,
  }) {
    final result = ForgetPeerRequest._();
    if (address != null) result.address = address;
    return result;
  }

  ForgetPeerRequest._();

  factory ForgetPeerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForgetPeerRequest()..mergeFromBuffer(data, registry);
  factory ForgetPeerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForgetPeerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ForgetPeerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForgetPeerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForgetPeerRequest copyWith(void Function(ForgetPeerRequest) updates) =>
      super.copyWith((message) => updates(message as ForgetPeerRequest)) as ForgetPeerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForgetPeerRequest() / ForgetPeerRequest.new instead')
  static ForgetPeerRequest create() => ForgetPeerRequest._();
  static $pb.GeneratedMessage $_createMessage() => ForgetPeerRequest._();
  @$core.override
  ForgetPeerRequest createEmptyInstance() => ForgetPeerRequest._();
  @$core.pragma('dart2js:noInline')
  static ForgetPeerRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForgetPeerRequest>(ForgetPeerRequest.$_createMessage);
  static ForgetPeerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class ForgetPeerResponse extends $pb.GeneratedMessage {
  factory ForgetPeerResponse() => ForgetPeerResponse._();

  ForgetPeerResponse._();

  factory ForgetPeerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForgetPeerResponse()..mergeFromBuffer(data, registry);
  factory ForgetPeerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForgetPeerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForgetPeerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ForgetPeerResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForgetPeerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForgetPeerResponse copyWith(void Function(ForgetPeerResponse) updates) =>
      super.copyWith((message) => updates(message as ForgetPeerResponse)) as ForgetPeerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForgetPeerResponse() / ForgetPeerResponse.new instead')
  static ForgetPeerResponse create() => ForgetPeerResponse._();
  static $pb.GeneratedMessage $_createMessage() => ForgetPeerResponse._();
  @$core.override
  ForgetPeerResponse createEmptyInstance() => ForgetPeerResponse._();
  @$core.pragma('dart2js:noInline')
  static ForgetPeerResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForgetPeerResponse>(ForgetPeerResponse.$_createMessage);
  static ForgetPeerResponse? _defaultInstance;
}

class ListPeersRequest extends $pb.GeneratedMessage {
  factory ListPeersRequest() => ListPeersRequest._();

  ListPeersRequest._();

  factory ListPeersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPeersRequest()..mergeFromBuffer(data, registry);
  factory ListPeersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPeersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListPeersRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPeersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPeersRequest copyWith(void Function(ListPeersRequest) updates) =>
      super.copyWith((message) => updates(message as ListPeersRequest)) as ListPeersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListPeersRequest() / ListPeersRequest.new instead')
  static ListPeersRequest create() => ListPeersRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListPeersRequest._();
  @$core.override
  ListPeersRequest createEmptyInstance() => ListPeersRequest._();
  @$core.pragma('dart2js:noInline')
  static ListPeersRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPeersRequest>(ListPeersRequest.$_createMessage);
  static ListPeersRequest? _defaultInstance;
}

class ListPeersResponse extends $pb.GeneratedMessage {
  factory ListPeersResponse({
    $core.String? peersJson,
  }) {
    final result = ListPeersResponse._();
    if (peersJson != null) result.peersJson = peersJson;
    return result;
  }

  ListPeersResponse._();

  factory ListPeersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPeersResponse()..mergeFromBuffer(data, registry);
  factory ListPeersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPeersResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListPeersResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'peersJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPeersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPeersResponse copyWith(void Function(ListPeersResponse) updates) =>
      super.copyWith((message) => updates(message as ListPeersResponse)) as ListPeersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListPeersResponse() / ListPeersResponse.new instead')
  static ListPeersResponse create() => ListPeersResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListPeersResponse._();
  @$core.override
  ListPeersResponse createEmptyInstance() => ListPeersResponse._();
  @$core.pragma('dart2js:noInline')
  static ListPeersResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPeersResponse>(ListPeersResponse.$_createMessage);
  static ListPeersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get peersJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set peersJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeersJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeersJson() => $_clearField(1);
}

class MineRequest extends $pb.GeneratedMessage {
  factory MineRequest({
    $fixnum.Int64? feeSats,
  }) {
    final result = MineRequest._();
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  MineRequest._();

  factory MineRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MineRequest()..mergeFromBuffer(data, registry);
  factory MineRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MineRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: MineRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MineRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MineRequest copyWith(void Function(MineRequest) updates) =>
      super.copyWith((message) => updates(message as MineRequest)) as MineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MineRequest() / MineRequest.new instead')
  static MineRequest create() => MineRequest._();
  static $pb.GeneratedMessage $_createMessage() => MineRequest._();
  @$core.override
  MineRequest createEmptyInstance() => MineRequest._();
  @$core.pragma('dart2js:noInline')
  static MineRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineRequest>(MineRequest.$_createMessage);
  static MineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => $_clearField(1);
}

class MineResponse extends $pb.GeneratedMessage {
  factory MineResponse({
    $core.String? bmmResultJson,
  }) {
    final result = MineResponse._();
    if (bmmResultJson != null) result.bmmResultJson = bmmResultJson;
    return result;
  }

  MineResponse._();

  factory MineResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MineResponse()..mergeFromBuffer(data, registry);
  factory MineResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MineResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: MineResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bmmResultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MineResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MineResponse copyWith(void Function(MineResponse) updates) =>
      super.copyWith((message) => updates(message as MineResponse)) as MineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MineResponse() / MineResponse.new instead')
  static MineResponse create() => MineResponse._();
  static $pb.GeneratedMessage $_createMessage() => MineResponse._();
  @$core.override
  MineResponse createEmptyInstance() => MineResponse._();
  @$core.pragma('dart2js:noInline')
  static MineResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineResponse>(MineResponse.$_createMessage);
  static MineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bmmResultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bmmResultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBmmResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBmmResultJson() => $_clearField(1);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? hash,
  }) {
    final result = GetBlockRequest._();
    if (hash != null) result.hash = hash;
    return result;
  }

  GetBlockRequest._();

  factory GetBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromBuffer(data, registry);
  factory GetBlockRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockRequest() / GetBlockRequest.new instead')
  static GetBlockRequest create() => GetBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockRequest._();
  @$core.override
  GetBlockRequest createEmptyInstance() => GetBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(GetBlockRequest.$_createMessage);
  static GetBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    $core.String? blockJson,
  }) {
    final result = GetBlockResponse._();
    if (blockJson != null) result.blockJson = blockJson;
    return result;
  }

  GetBlockResponse._();

  factory GetBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse()..mergeFromBuffer(data, registry);
  factory GetBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBlockResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'blockJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockResponse() / GetBlockResponse.new instead')
  static GetBlockResponse create() => GetBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockResponse._();
  @$core.override
  GetBlockResponse createEmptyInstance() => GetBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(GetBlockResponse.$_createMessage);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockJson() => $_clearField(1);
}

class GetBestMainchainBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBestMainchainBlockHashRequest() => GetBestMainchainBlockHashRequest._();

  GetBestMainchainBlockHashRequest._();

  factory GetBestMainchainBlockHashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestMainchainBlockHashRequest()..mergeFromBuffer(data, registry);
  factory GetBestMainchainBlockHashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestMainchainBlockHashRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBestMainchainBlockHashRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestMainchainBlockHashRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestMainchainBlockHashRequest copyWith(void Function(GetBestMainchainBlockHashRequest) updates) =>
      super.copyWith((message) => updates(message as GetBestMainchainBlockHashRequest))
          as GetBestMainchainBlockHashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBestMainchainBlockHashRequest() / GetBestMainchainBlockHashRequest.new instead')
  static GetBestMainchainBlockHashRequest create() => GetBestMainchainBlockHashRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBestMainchainBlockHashRequest._();
  @$core.override
  GetBestMainchainBlockHashRequest createEmptyInstance() => GetBestMainchainBlockHashRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestMainchainBlockHashRequest>(
          GetBestMainchainBlockHashRequest.$_createMessage);
  static GetBestMainchainBlockHashRequest? _defaultInstance;
}

class GetBestMainchainBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBestMainchainBlockHashResponse({
    $core.String? hash,
  }) {
    final result = GetBestMainchainBlockHashResponse._();
    if (hash != null) result.hash = hash;
    return result;
  }

  GetBestMainchainBlockHashResponse._();

  factory GetBestMainchainBlockHashResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestMainchainBlockHashResponse()..mergeFromBuffer(data, registry);
  factory GetBestMainchainBlockHashResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestMainchainBlockHashResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestMainchainBlockHashResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBestMainchainBlockHashResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestMainchainBlockHashResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestMainchainBlockHashResponse copyWith(void Function(GetBestMainchainBlockHashResponse) updates) =>
      super.copyWith((message) => updates(message as GetBestMainchainBlockHashResponse))
          as GetBestMainchainBlockHashResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBestMainchainBlockHashResponse() / GetBestMainchainBlockHashResponse.new instead')
  static GetBestMainchainBlockHashResponse create() => GetBestMainchainBlockHashResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBestMainchainBlockHashResponse._();
  @$core.override
  GetBestMainchainBlockHashResponse createEmptyInstance() => GetBestMainchainBlockHashResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBestMainchainBlockHashResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestMainchainBlockHashResponse>(
          GetBestMainchainBlockHashResponse.$_createMessage);
  static GetBestMainchainBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);
}

class GetBestSidechainBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBestSidechainBlockHashRequest() => GetBestSidechainBlockHashRequest._();

  GetBestSidechainBlockHashRequest._();

  factory GetBestSidechainBlockHashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestSidechainBlockHashRequest()..mergeFromBuffer(data, registry);
  factory GetBestSidechainBlockHashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestSidechainBlockHashRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBestSidechainBlockHashRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestSidechainBlockHashRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestSidechainBlockHashRequest copyWith(void Function(GetBestSidechainBlockHashRequest) updates) =>
      super.copyWith((message) => updates(message as GetBestSidechainBlockHashRequest))
          as GetBestSidechainBlockHashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBestSidechainBlockHashRequest() / GetBestSidechainBlockHashRequest.new instead')
  static GetBestSidechainBlockHashRequest create() => GetBestSidechainBlockHashRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBestSidechainBlockHashRequest._();
  @$core.override
  GetBestSidechainBlockHashRequest createEmptyInstance() => GetBestSidechainBlockHashRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestSidechainBlockHashRequest>(
          GetBestSidechainBlockHashRequest.$_createMessage);
  static GetBestSidechainBlockHashRequest? _defaultInstance;
}

class GetBestSidechainBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBestSidechainBlockHashResponse({
    $core.String? hash,
  }) {
    final result = GetBestSidechainBlockHashResponse._();
    if (hash != null) result.hash = hash;
    return result;
  }

  GetBestSidechainBlockHashResponse._();

  factory GetBestSidechainBlockHashResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestSidechainBlockHashResponse()..mergeFromBuffer(data, registry);
  factory GetBestSidechainBlockHashResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBestSidechainBlockHashResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBestSidechainBlockHashResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBestSidechainBlockHashResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestSidechainBlockHashResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBestSidechainBlockHashResponse copyWith(void Function(GetBestSidechainBlockHashResponse) updates) =>
      super.copyWith((message) => updates(message as GetBestSidechainBlockHashResponse))
          as GetBestSidechainBlockHashResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBestSidechainBlockHashResponse() / GetBestSidechainBlockHashResponse.new instead')
  static GetBestSidechainBlockHashResponse create() => GetBestSidechainBlockHashResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBestSidechainBlockHashResponse._();
  @$core.override
  GetBestSidechainBlockHashResponse createEmptyInstance() => GetBestSidechainBlockHashResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBestSidechainBlockHashResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBestSidechainBlockHashResponse>(
          GetBestSidechainBlockHashResponse.$_createMessage);
  static GetBestSidechainBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);
}

class GetBmmInclusionsRequest extends $pb.GeneratedMessage {
  factory GetBmmInclusionsRequest({
    $core.String? blockHash,
  }) {
    final result = GetBmmInclusionsRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  GetBmmInclusionsRequest._();

  factory GetBmmInclusionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmInclusionsRequest()..mergeFromBuffer(data, registry);
  factory GetBmmInclusionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmInclusionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBmmInclusionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmInclusionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmInclusionsRequest copyWith(void Function(GetBmmInclusionsRequest) updates) =>
      super.copyWith((message) => updates(message as GetBmmInclusionsRequest)) as GetBmmInclusionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmInclusionsRequest() / GetBmmInclusionsRequest.new instead')
  static GetBmmInclusionsRequest create() => GetBmmInclusionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmInclusionsRequest._();
  @$core.override
  GetBmmInclusionsRequest createEmptyInstance() => GetBmmInclusionsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmInclusionsRequest>(GetBmmInclusionsRequest.$_createMessage);
  static GetBmmInclusionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
}

class GetBmmInclusionsResponse extends $pb.GeneratedMessage {
  factory GetBmmInclusionsResponse({
    $core.String? inclusions,
  }) {
    final result = GetBmmInclusionsResponse._();
    if (inclusions != null) result.inclusions = inclusions;
    return result;
  }

  GetBmmInclusionsResponse._();

  factory GetBmmInclusionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmInclusionsResponse()..mergeFromBuffer(data, registry);
  factory GetBmmInclusionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmInclusionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmInclusionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetBmmInclusionsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'inclusions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmInclusionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmInclusionsResponse copyWith(void Function(GetBmmInclusionsResponse) updates) =>
      super.copyWith((message) => updates(message as GetBmmInclusionsResponse)) as GetBmmInclusionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmInclusionsResponse() / GetBmmInclusionsResponse.new instead')
  static GetBmmInclusionsResponse create() => GetBmmInclusionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmInclusionsResponse._();
  @$core.override
  GetBmmInclusionsResponse createEmptyInstance() => GetBmmInclusionsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBmmInclusionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmInclusionsResponse>(GetBmmInclusionsResponse.$_createMessage);
  static GetBmmInclusionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inclusions => $_getSZ(0);
  @$pb.TagNumber(1)
  set inclusions($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInclusions() => $_has(0);
  @$pb.TagNumber(1)
  void clearInclusions() => $_clearField(1);
}

class GetWalletUtxosRequest extends $pb.GeneratedMessage {
  factory GetWalletUtxosRequest() => GetWalletUtxosRequest._();

  GetWalletUtxosRequest._();

  factory GetWalletUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletUtxosRequest()..mergeFromBuffer(data, registry);
  factory GetWalletUtxosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetWalletUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletUtxosRequest copyWith(void Function(GetWalletUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletUtxosRequest)) as GetWalletUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletUtxosRequest() / GetWalletUtxosRequest.new instead')
  static GetWalletUtxosRequest create() => GetWalletUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletUtxosRequest._();
  @$core.override
  GetWalletUtxosRequest createEmptyInstance() => GetWalletUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletUtxosRequest>(GetWalletUtxosRequest.$_createMessage);
  static GetWalletUtxosRequest? _defaultInstance;
}

class GetWalletUtxosResponse extends $pb.GeneratedMessage {
  factory GetWalletUtxosResponse({
    $core.String? utxosJson,
  }) {
    final result = GetWalletUtxosResponse._();
    if (utxosJson != null) result.utxosJson = utxosJson;
    return result;
  }

  GetWalletUtxosResponse._();

  factory GetWalletUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletUtxosResponse()..mergeFromBuffer(data, registry);
  factory GetWalletUtxosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetWalletUtxosResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletUtxosResponse copyWith(void Function(GetWalletUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletUtxosResponse)) as GetWalletUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletUtxosResponse() / GetWalletUtxosResponse.new instead')
  static GetWalletUtxosResponse create() => GetWalletUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletUtxosResponse._();
  @$core.override
  GetWalletUtxosResponse createEmptyInstance() => GetWalletUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWalletUtxosResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletUtxosResponse>(GetWalletUtxosResponse.$_createMessage);
  static GetWalletUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => $_clearField(1);
}

class ListUtxosRequest extends $pb.GeneratedMessage {
  factory ListUtxosRequest() => ListUtxosRequest._();

  ListUtxosRequest._();

  factory ListUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosRequest()..mergeFromBuffer(data, registry);
  factory ListUtxosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosRequest copyWith(void Function(ListUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as ListUtxosRequest)) as ListUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUtxosRequest() / ListUtxosRequest.new instead')
  static ListUtxosRequest create() => ListUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListUtxosRequest._();
  @$core.override
  ListUtxosRequest createEmptyInstance() => ListUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static ListUtxosRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosRequest>(ListUtxosRequest.$_createMessage);
  static ListUtxosRequest? _defaultInstance;
}

class ListUtxosResponse extends $pb.GeneratedMessage {
  factory ListUtxosResponse({
    $core.String? utxosJson,
  }) {
    final result = ListUtxosResponse._();
    if (utxosJson != null) result.utxosJson = utxosJson;
    return result;
  }

  ListUtxosResponse._();

  factory ListUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosResponse()..mergeFromBuffer(data, registry);
  factory ListUtxosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListUtxosResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosResponse copyWith(void Function(ListUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as ListUtxosResponse)) as ListUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUtxosResponse() / ListUtxosResponse.new instead')
  static ListUtxosResponse create() => ListUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListUtxosResponse._();
  @$core.override
  ListUtxosResponse createEmptyInstance() => ListUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static ListUtxosResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosResponse>(ListUtxosResponse.$_createMessage);
  static ListUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => $_clearField(1);
}

class RemoveFromMempoolRequest extends $pb.GeneratedMessage {
  factory RemoveFromMempoolRequest({
    $core.String? txid,
  }) {
    final result = RemoveFromMempoolRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  RemoveFromMempoolRequest._();

  factory RemoveFromMempoolRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromMempoolRequest()..mergeFromBuffer(data, registry);
  factory RemoveFromMempoolRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromMempoolRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: RemoveFromMempoolRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromMempoolRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromMempoolRequest copyWith(void Function(RemoveFromMempoolRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveFromMempoolRequest)) as RemoveFromMempoolRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoveFromMempoolRequest() / RemoveFromMempoolRequest.new instead')
  static RemoveFromMempoolRequest create() => RemoveFromMempoolRequest._();
  static $pb.GeneratedMessage $_createMessage() => RemoveFromMempoolRequest._();
  @$core.override
  RemoveFromMempoolRequest createEmptyInstance() => RemoveFromMempoolRequest._();
  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromMempoolRequest>(RemoveFromMempoolRequest.$_createMessage);
  static RemoveFromMempoolRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class RemoveFromMempoolResponse extends $pb.GeneratedMessage {
  factory RemoveFromMempoolResponse() => RemoveFromMempoolResponse._();

  RemoveFromMempoolResponse._();

  factory RemoveFromMempoolResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromMempoolResponse()..mergeFromBuffer(data, registry);
  factory RemoveFromMempoolResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromMempoolResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveFromMempoolResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: RemoveFromMempoolResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromMempoolResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromMempoolResponse copyWith(void Function(RemoveFromMempoolResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveFromMempoolResponse)) as RemoveFromMempoolResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoveFromMempoolResponse() / RemoveFromMempoolResponse.new instead')
  static RemoveFromMempoolResponse create() => RemoveFromMempoolResponse._();
  static $pb.GeneratedMessage $_createMessage() => RemoveFromMempoolResponse._();
  @$core.override
  RemoveFromMempoolResponse createEmptyInstance() => RemoveFromMempoolResponse._();
  @$core.pragma('dart2js:noInline')
  static RemoveFromMempoolResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromMempoolResponse>(RemoveFromMempoolResponse.$_createMessage);
  static RemoveFromMempoolResponse? _defaultInstance;
}

class GetLatestFailedWithdrawalBundleHeightRequest extends $pb.GeneratedMessage {
  factory GetLatestFailedWithdrawalBundleHeightRequest() => GetLatestFailedWithdrawalBundleHeightRequest._();

  GetLatestFailedWithdrawalBundleHeightRequest._();

  factory GetLatestFailedWithdrawalBundleHeightRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLatestFailedWithdrawalBundleHeightRequest()..mergeFromBuffer(data, registry);
  factory GetLatestFailedWithdrawalBundleHeightRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLatestFailedWithdrawalBundleHeightRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetLatestFailedWithdrawalBundleHeightRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestFailedWithdrawalBundleHeightRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestFailedWithdrawalBundleHeightRequest copyWith(
          void Function(GetLatestFailedWithdrawalBundleHeightRequest) updates) =>
      super.copyWith((message) => updates(message as GetLatestFailedWithdrawalBundleHeightRequest))
          as GetLatestFailedWithdrawalBundleHeightRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetLatestFailedWithdrawalBundleHeightRequest() / GetLatestFailedWithdrawalBundleHeightRequest.new instead')
  static GetLatestFailedWithdrawalBundleHeightRequest create() => GetLatestFailedWithdrawalBundleHeightRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetLatestFailedWithdrawalBundleHeightRequest._();
  @$core.override
  GetLatestFailedWithdrawalBundleHeightRequest createEmptyInstance() =>
      GetLatestFailedWithdrawalBundleHeightRequest._();
  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetLatestFailedWithdrawalBundleHeightRequest>(
          GetLatestFailedWithdrawalBundleHeightRequest.$_createMessage);
  static GetLatestFailedWithdrawalBundleHeightRequest? _defaultInstance;
}

class GetLatestFailedWithdrawalBundleHeightResponse extends $pb.GeneratedMessage {
  factory GetLatestFailedWithdrawalBundleHeightResponse({
    $fixnum.Int64? height,
  }) {
    final result = GetLatestFailedWithdrawalBundleHeightResponse._();
    if (height != null) result.height = height;
    return result;
  }

  GetLatestFailedWithdrawalBundleHeightResponse._();

  factory GetLatestFailedWithdrawalBundleHeightResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLatestFailedWithdrawalBundleHeightResponse()..mergeFromBuffer(data, registry);
  factory GetLatestFailedWithdrawalBundleHeightResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLatestFailedWithdrawalBundleHeightResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLatestFailedWithdrawalBundleHeightResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetLatestFailedWithdrawalBundleHeightResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestFailedWithdrawalBundleHeightResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestFailedWithdrawalBundleHeightResponse copyWith(
          void Function(GetLatestFailedWithdrawalBundleHeightResponse) updates) =>
      super.copyWith((message) => updates(message as GetLatestFailedWithdrawalBundleHeightResponse))
          as GetLatestFailedWithdrawalBundleHeightResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetLatestFailedWithdrawalBundleHeightResponse() / GetLatestFailedWithdrawalBundleHeightResponse.new instead')
  static GetLatestFailedWithdrawalBundleHeightResponse create() => GetLatestFailedWithdrawalBundleHeightResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetLatestFailedWithdrawalBundleHeightResponse._();
  @$core.override
  GetLatestFailedWithdrawalBundleHeightResponse createEmptyInstance() =>
      GetLatestFailedWithdrawalBundleHeightResponse._();
  @$core.pragma('dart2js:noInline')
  static GetLatestFailedWithdrawalBundleHeightResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetLatestFailedWithdrawalBundleHeightResponse>(
          GetLatestFailedWithdrawalBundleHeightResponse.$_createMessage);
  static GetLatestFailedWithdrawalBundleHeightResponse? _defaultInstance;

  /// 0 means no failed bundle.
  @$pb.TagNumber(1)
  $fixnum.Int64 get height => $_getI64(0);
  @$pb.TagNumber(1)
  set height($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);
}

class GenerateMnemonicRequest extends $pb.GeneratedMessage {
  factory GenerateMnemonicRequest() => GenerateMnemonicRequest._();

  GenerateMnemonicRequest._();

  factory GenerateMnemonicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicRequest()..mergeFromBuffer(data, registry);
  factory GenerateMnemonicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GenerateMnemonicRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicRequest copyWith(void Function(GenerateMnemonicRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateMnemonicRequest)) as GenerateMnemonicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateMnemonicRequest() / GenerateMnemonicRequest.new instead')
  static GenerateMnemonicRequest create() => GenerateMnemonicRequest._();
  static $pb.GeneratedMessage $_createMessage() => GenerateMnemonicRequest._();
  @$core.override
  GenerateMnemonicRequest createEmptyInstance() => GenerateMnemonicRequest._();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicRequest>(GenerateMnemonicRequest.$_createMessage);
  static GenerateMnemonicRequest? _defaultInstance;
}

class GenerateMnemonicResponse extends $pb.GeneratedMessage {
  factory GenerateMnemonicResponse({
    $core.String? mnemonic,
  }) {
    final result = GenerateMnemonicResponse._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  GenerateMnemonicResponse._();

  factory GenerateMnemonicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicResponse()..mergeFromBuffer(data, registry);
  factory GenerateMnemonicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GenerateMnemonicResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicResponse copyWith(void Function(GenerateMnemonicResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateMnemonicResponse)) as GenerateMnemonicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateMnemonicResponse() / GenerateMnemonicResponse.new instead')
  static GenerateMnemonicResponse create() => GenerateMnemonicResponse._();
  static $pb.GeneratedMessage $_createMessage() => GenerateMnemonicResponse._();
  @$core.override
  GenerateMnemonicResponse createEmptyInstance() => GenerateMnemonicResponse._();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicResponse>(GenerateMnemonicResponse.$_createMessage);
  static GenerateMnemonicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);
}

class SetSeedFromMnemonicRequest extends $pb.GeneratedMessage {
  factory SetSeedFromMnemonicRequest({
    $core.String? mnemonic,
  }) {
    final result = SetSeedFromMnemonicRequest._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  SetSeedFromMnemonicRequest._();

  factory SetSeedFromMnemonicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetSeedFromMnemonicRequest()..mergeFromBuffer(data, registry);
  factory SetSeedFromMnemonicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetSeedFromMnemonicRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: SetSeedFromMnemonicRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSeedFromMnemonicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSeedFromMnemonicRequest copyWith(void Function(SetSeedFromMnemonicRequest) updates) =>
      super.copyWith((message) => updates(message as SetSeedFromMnemonicRequest)) as SetSeedFromMnemonicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetSeedFromMnemonicRequest() / SetSeedFromMnemonicRequest.new instead')
  static SetSeedFromMnemonicRequest create() => SetSeedFromMnemonicRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetSeedFromMnemonicRequest._();
  @$core.override
  SetSeedFromMnemonicRequest createEmptyInstance() => SetSeedFromMnemonicRequest._();
  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetSeedFromMnemonicRequest>(SetSeedFromMnemonicRequest.$_createMessage);
  static SetSeedFromMnemonicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);
}

class SetSeedFromMnemonicResponse extends $pb.GeneratedMessage {
  factory SetSeedFromMnemonicResponse() => SetSeedFromMnemonicResponse._();

  SetSeedFromMnemonicResponse._();

  factory SetSeedFromMnemonicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetSeedFromMnemonicResponse()..mergeFromBuffer(data, registry);
  factory SetSeedFromMnemonicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetSeedFromMnemonicResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetSeedFromMnemonicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: SetSeedFromMnemonicResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSeedFromMnemonicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSeedFromMnemonicResponse copyWith(void Function(SetSeedFromMnemonicResponse) updates) =>
      super.copyWith((message) => updates(message as SetSeedFromMnemonicResponse)) as SetSeedFromMnemonicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetSeedFromMnemonicResponse() / SetSeedFromMnemonicResponse.new instead')
  static SetSeedFromMnemonicResponse create() => SetSeedFromMnemonicResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetSeedFromMnemonicResponse._();
  @$core.override
  SetSeedFromMnemonicResponse createEmptyInstance() => SetSeedFromMnemonicResponse._();
  @$core.pragma('dart2js:noInline')
  static SetSeedFromMnemonicResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetSeedFromMnemonicResponse>(SetSeedFromMnemonicResponse.$_createMessage);
  static SetSeedFromMnemonicResponse? _defaultInstance;
}

class CallRawRequest extends $pb.GeneratedMessage {
  factory CallRawRequest({
    $core.String? method,
    $core.String? paramsJson,
  }) {
    final result = CallRawRequest._();
    if (method != null) result.method = method;
    if (paramsJson != null) result.paramsJson = paramsJson;
    return result;
  }

  CallRawRequest._();

  factory CallRawRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallRawRequest()..mergeFromBuffer(data, registry);
  factory CallRawRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallRawRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CallRawRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..aOS(2, _omitFieldNames ? '' : 'paramsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallRawRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallRawRequest copyWith(void Function(CallRawRequest) updates) =>
      super.copyWith((message) => updates(message as CallRawRequest)) as CallRawRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CallRawRequest() / CallRawRequest.new instead')
  static CallRawRequest create() => CallRawRequest._();
  static $pb.GeneratedMessage $_createMessage() => CallRawRequest._();
  @$core.override
  CallRawRequest createEmptyInstance() => CallRawRequest._();
  @$core.pragma('dart2js:noInline')
  static CallRawRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallRawRequest>(CallRawRequest.$_createMessage);
  static CallRawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get paramsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set paramsJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParamsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearParamsJson() => $_clearField(2);
}

class CallRawResponse extends $pb.GeneratedMessage {
  factory CallRawResponse({
    $core.String? resultJson,
  }) {
    final result = CallRawResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  CallRawResponse._();

  factory CallRawResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallRawResponse()..mergeFromBuffer(data, registry);
  factory CallRawResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallRawResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallRawResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CallRawResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallRawResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallRawResponse copyWith(void Function(CallRawResponse) updates) =>
      super.copyWith((message) => updates(message as CallRawResponse)) as CallRawResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CallRawResponse() / CallRawResponse.new instead')
  static CallRawResponse create() => CallRawResponse._();
  static $pb.GeneratedMessage $_createMessage() => CallRawResponse._();
  @$core.override
  CallRawResponse createEmptyInstance() => CallRawResponse._();
  @$core.pragma('dart2js:noInline')
  static CallRawResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallRawResponse>(CallRawResponse.$_createMessage);
  static CallRawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
}

class GetWalletAddressesRequest extends $pb.GeneratedMessage {
  factory GetWalletAddressesRequest() => GetWalletAddressesRequest._();

  GetWalletAddressesRequest._();

  factory GetWalletAddressesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletAddressesRequest()..mergeFromBuffer(data, registry);
  factory GetWalletAddressesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletAddressesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetWalletAddressesRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletAddressesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletAddressesRequest copyWith(void Function(GetWalletAddressesRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletAddressesRequest)) as GetWalletAddressesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletAddressesRequest() / GetWalletAddressesRequest.new instead')
  static GetWalletAddressesRequest create() => GetWalletAddressesRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletAddressesRequest._();
  @$core.override
  GetWalletAddressesRequest createEmptyInstance() => GetWalletAddressesRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletAddressesRequest>(GetWalletAddressesRequest.$_createMessage);
  static GetWalletAddressesRequest? _defaultInstance;
}

class GetWalletAddressesResponse extends $pb.GeneratedMessage {
  factory GetWalletAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final result = GetWalletAddressesResponse._();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  GetWalletAddressesResponse._();

  factory GetWalletAddressesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletAddressesResponse()..mergeFromBuffer(data, registry);
  factory GetWalletAddressesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletAddressesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletAddressesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetWalletAddressesResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletAddressesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletAddressesResponse copyWith(void Function(GetWalletAddressesResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletAddressesResponse)) as GetWalletAddressesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletAddressesResponse() / GetWalletAddressesResponse.new instead')
  static GetWalletAddressesResponse create() => GetWalletAddressesResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletAddressesResponse._();
  @$core.override
  GetWalletAddressesResponse createEmptyInstance() => GetWalletAddressesResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWalletAddressesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletAddressesResponse>(GetWalletAddressesResponse.$_createMessage);
  static GetWalletAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get addresses => $_getList(0);
}

class OpenapiSchemaRequest extends $pb.GeneratedMessage {
  factory OpenapiSchemaRequest() => OpenapiSchemaRequest._();

  OpenapiSchemaRequest._();

  factory OpenapiSchemaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenapiSchemaRequest()..mergeFromBuffer(data, registry);
  factory OpenapiSchemaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenapiSchemaRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: OpenapiSchemaRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenapiSchemaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenapiSchemaRequest copyWith(void Function(OpenapiSchemaRequest) updates) =>
      super.copyWith((message) => updates(message as OpenapiSchemaRequest)) as OpenapiSchemaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OpenapiSchemaRequest() / OpenapiSchemaRequest.new instead')
  static OpenapiSchemaRequest create() => OpenapiSchemaRequest._();
  static $pb.GeneratedMessage $_createMessage() => OpenapiSchemaRequest._();
  @$core.override
  OpenapiSchemaRequest createEmptyInstance() => OpenapiSchemaRequest._();
  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OpenapiSchemaRequest>(OpenapiSchemaRequest.$_createMessage);
  static OpenapiSchemaRequest? _defaultInstance;
}

class OpenapiSchemaResponse extends $pb.GeneratedMessage {
  factory OpenapiSchemaResponse({
    $core.String? schemaJson,
  }) {
    final result = OpenapiSchemaResponse._();
    if (schemaJson != null) result.schemaJson = schemaJson;
    return result;
  }

  OpenapiSchemaResponse._();

  factory OpenapiSchemaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenapiSchemaResponse()..mergeFromBuffer(data, registry);
  factory OpenapiSchemaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenapiSchemaResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpenapiSchemaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: OpenapiSchemaResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'schemaJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenapiSchemaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenapiSchemaResponse copyWith(void Function(OpenapiSchemaResponse) updates) =>
      super.copyWith((message) => updates(message as OpenapiSchemaResponse)) as OpenapiSchemaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OpenapiSchemaResponse() / OpenapiSchemaResponse.new instead')
  static OpenapiSchemaResponse create() => OpenapiSchemaResponse._();
  static $pb.GeneratedMessage $_createMessage() => OpenapiSchemaResponse._();
  @$core.override
  OpenapiSchemaResponse createEmptyInstance() => OpenapiSchemaResponse._();
  @$core.pragma('dart2js:noInline')
  static OpenapiSchemaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OpenapiSchemaResponse>(OpenapiSchemaResponse.$_createMessage);
  static OpenapiSchemaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get schemaJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set schemaJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchemaJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaJson() => $_clearField(1);
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
    final result = CreateSwapRequest._();
    if (l2AmountSats != null) result.l2AmountSats = l2AmountSats;
    if (l1AmountSats != null) result.l1AmountSats = l1AmountSats;
    if (l1RecipientAddress != null) result.l1RecipientAddress = l1RecipientAddress;
    if (parentChain != null) result.parentChain = parentChain;
    if (l2Recipient != null) result.l2Recipient = l2Recipient;
    if (requiredConfirmations != null) result.requiredConfirmations = requiredConfirmations;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CreateSwapRequest._();

  factory CreateSwapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSwapRequest()..mergeFromBuffer(data, registry);
  factory CreateSwapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSwapRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSwapRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CreateSwapRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'l2AmountSats')
    ..aInt64(2, _omitFieldNames ? '' : 'l1AmountSats')
    ..aOS(3, _omitFieldNames ? '' : 'l1RecipientAddress')
    ..aOS(4, _omitFieldNames ? '' : 'parentChain')
    ..aOS(5, _omitFieldNames ? '' : 'l2Recipient')
    ..aI(6, _omitFieldNames ? '' : 'requiredConfirmations')
    ..aInt64(7, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSwapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSwapRequest copyWith(void Function(CreateSwapRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSwapRequest)) as CreateSwapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSwapRequest() / CreateSwapRequest.new instead')
  static CreateSwapRequest create() => CreateSwapRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateSwapRequest._();
  @$core.override
  CreateSwapRequest createEmptyInstance() => CreateSwapRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSwapRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSwapRequest>(CreateSwapRequest.$_createMessage);
  static CreateSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get l2AmountSats => $_getI64(0);
  @$pb.TagNumber(1)
  set l2AmountSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasL2AmountSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearL2AmountSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get l1AmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set l1AmountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1AmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1AmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get l1RecipientAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set l1RecipientAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasL1RecipientAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearL1RecipientAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentChain => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentChain($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentChain() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentChain() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get l2Recipient => $_getSZ(4);
  @$pb.TagNumber(5)
  set l2Recipient($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasL2Recipient() => $_has(4);
  @$pb.TagNumber(5)
  void clearL2Recipient() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get requiredConfirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set requiredConfirmations($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRequiredConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequiredConfirmations() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get feeSats => $_getI64(6);
  @$pb.TagNumber(7)
  set feeSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFeeSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeSats() => $_clearField(7);
}

class CreateSwapResponse extends $pb.GeneratedMessage {
  factory CreateSwapResponse({
    $core.String? swapId,
    $core.String? txid,
  }) {
    final result = CreateSwapResponse._();
    if (swapId != null) result.swapId = swapId;
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateSwapResponse._();

  factory CreateSwapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSwapResponse()..mergeFromBuffer(data, registry);
  factory CreateSwapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSwapResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSwapResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: CreateSwapResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSwapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSwapResponse copyWith(void Function(CreateSwapResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSwapResponse)) as CreateSwapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSwapResponse() / CreateSwapResponse.new instead')
  static CreateSwapResponse create() => CreateSwapResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateSwapResponse._();
  @$core.override
  CreateSwapResponse createEmptyInstance() => CreateSwapResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateSwapResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSwapResponse>(CreateSwapResponse.$_createMessage);
  static CreateSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class ClaimSwapRequest extends $pb.GeneratedMessage {
  factory ClaimSwapRequest({
    $core.String? swapId,
    $core.String? l2ClaimerAddress,
  }) {
    final result = ClaimSwapRequest._();
    if (swapId != null) result.swapId = swapId;
    if (l2ClaimerAddress != null) result.l2ClaimerAddress = l2ClaimerAddress;
    return result;
  }

  ClaimSwapRequest._();

  factory ClaimSwapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClaimSwapRequest()..mergeFromBuffer(data, registry);
  factory ClaimSwapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClaimSwapRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClaimSwapRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ClaimSwapRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'l2ClaimerAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClaimSwapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClaimSwapRequest copyWith(void Function(ClaimSwapRequest) updates) =>
      super.copyWith((message) => updates(message as ClaimSwapRequest)) as ClaimSwapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClaimSwapRequest() / ClaimSwapRequest.new instead')
  static ClaimSwapRequest create() => ClaimSwapRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClaimSwapRequest._();
  @$core.override
  ClaimSwapRequest createEmptyInstance() => ClaimSwapRequest._();
  @$core.pragma('dart2js:noInline')
  static ClaimSwapRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClaimSwapRequest>(ClaimSwapRequest.$_createMessage);
  static ClaimSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get l2ClaimerAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set l2ClaimerAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL2ClaimerAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearL2ClaimerAddress() => $_clearField(2);
}

class ClaimSwapResponse extends $pb.GeneratedMessage {
  factory ClaimSwapResponse({
    $core.String? txid,
  }) {
    final result = ClaimSwapResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  ClaimSwapResponse._();

  factory ClaimSwapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClaimSwapResponse()..mergeFromBuffer(data, registry);
  factory ClaimSwapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClaimSwapResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClaimSwapResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ClaimSwapResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClaimSwapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClaimSwapResponse copyWith(void Function(ClaimSwapResponse) updates) =>
      super.copyWith((message) => updates(message as ClaimSwapResponse)) as ClaimSwapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClaimSwapResponse() / ClaimSwapResponse.new instead')
  static ClaimSwapResponse create() => ClaimSwapResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClaimSwapResponse._();
  @$core.override
  ClaimSwapResponse createEmptyInstance() => ClaimSwapResponse._();
  @$core.pragma('dart2js:noInline')
  static ClaimSwapResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClaimSwapResponse>(ClaimSwapResponse.$_createMessage);
  static ClaimSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetSwapStatusRequest extends $pb.GeneratedMessage {
  factory GetSwapStatusRequest({
    $core.String? swapId,
  }) {
    final result = GetSwapStatusRequest._();
    if (swapId != null) result.swapId = swapId;
    return result;
  }

  GetSwapStatusRequest._();

  factory GetSwapStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSwapStatusRequest()..mergeFromBuffer(data, registry);
  factory GetSwapStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSwapStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSwapStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetSwapStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSwapStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSwapStatusRequest copyWith(void Function(GetSwapStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetSwapStatusRequest)) as GetSwapStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSwapStatusRequest() / GetSwapStatusRequest.new instead')
  static GetSwapStatusRequest create() => GetSwapStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSwapStatusRequest._();
  @$core.override
  GetSwapStatusRequest createEmptyInstance() => GetSwapStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSwapStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSwapStatusRequest>(GetSwapStatusRequest.$_createMessage);
  static GetSwapStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => $_clearField(1);
}

class GetSwapStatusResponse extends $pb.GeneratedMessage {
  factory GetSwapStatusResponse({
    $core.String? swapJson,
  }) {
    final result = GetSwapStatusResponse._();
    if (swapJson != null) result.swapJson = swapJson;
    return result;
  }

  GetSwapStatusResponse._();

  factory GetSwapStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSwapStatusResponse()..mergeFromBuffer(data, registry);
  factory GetSwapStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSwapStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSwapStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: GetSwapStatusResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSwapStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSwapStatusResponse copyWith(void Function(GetSwapStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetSwapStatusResponse)) as GetSwapStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSwapStatusResponse() / GetSwapStatusResponse.new instead')
  static GetSwapStatusResponse create() => GetSwapStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSwapStatusResponse._();
  @$core.override
  GetSwapStatusResponse createEmptyInstance() => GetSwapStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSwapStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSwapStatusResponse>(GetSwapStatusResponse.$_createMessage);
  static GetSwapStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapJson() => $_clearField(1);
}

class ListSwapsRequest extends $pb.GeneratedMessage {
  factory ListSwapsRequest() => ListSwapsRequest._();

  ListSwapsRequest._();

  factory ListSwapsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsRequest()..mergeFromBuffer(data, registry);
  factory ListSwapsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListSwapsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsRequest copyWith(void Function(ListSwapsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSwapsRequest)) as ListSwapsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSwapsRequest() / ListSwapsRequest.new instead')
  static ListSwapsRequest create() => ListSwapsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSwapsRequest._();
  @$core.override
  ListSwapsRequest createEmptyInstance() => ListSwapsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSwapsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsRequest>(ListSwapsRequest.$_createMessage);
  static ListSwapsRequest? _defaultInstance;
}

class ListSwapsResponse extends $pb.GeneratedMessage {
  factory ListSwapsResponse({
    $core.String? swapsJson,
  }) {
    final result = ListSwapsResponse._();
    if (swapsJson != null) result.swapsJson = swapsJson;
    return result;
  }

  ListSwapsResponse._();

  factory ListSwapsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsResponse()..mergeFromBuffer(data, registry);
  factory ListSwapsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListSwapsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsResponse copyWith(void Function(ListSwapsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSwapsResponse)) as ListSwapsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSwapsResponse() / ListSwapsResponse.new instead')
  static ListSwapsResponse create() => ListSwapsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSwapsResponse._();
  @$core.override
  ListSwapsResponse createEmptyInstance() => ListSwapsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSwapsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSwapsResponse>(ListSwapsResponse.$_createMessage);
  static ListSwapsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapsJson() => $_clearField(1);
}

class ListSwapsByRecipientRequest extends $pb.GeneratedMessage {
  factory ListSwapsByRecipientRequest({
    $core.String? recipient,
  }) {
    final result = ListSwapsByRecipientRequest._();
    if (recipient != null) result.recipient = recipient;
    return result;
  }

  ListSwapsByRecipientRequest._();

  factory ListSwapsByRecipientRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsByRecipientRequest()..mergeFromBuffer(data, registry);
  factory ListSwapsByRecipientRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsByRecipientRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsByRecipientRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListSwapsByRecipientRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'recipient')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsByRecipientRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsByRecipientRequest copyWith(void Function(ListSwapsByRecipientRequest) updates) =>
      super.copyWith((message) => updates(message as ListSwapsByRecipientRequest)) as ListSwapsByRecipientRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSwapsByRecipientRequest() / ListSwapsByRecipientRequest.new instead')
  static ListSwapsByRecipientRequest create() => ListSwapsByRecipientRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSwapsByRecipientRequest._();
  @$core.override
  ListSwapsByRecipientRequest createEmptyInstance() => ListSwapsByRecipientRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSwapsByRecipientRequest>(ListSwapsByRecipientRequest.$_createMessage);
  static ListSwapsByRecipientRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipient => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipient($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecipient() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipient() => $_clearField(1);
}

class ListSwapsByRecipientResponse extends $pb.GeneratedMessage {
  factory ListSwapsByRecipientResponse({
    $core.String? swapsJson,
  }) {
    final result = ListSwapsByRecipientResponse._();
    if (swapsJson != null) result.swapsJson = swapsJson;
    return result;
  }

  ListSwapsByRecipientResponse._();

  factory ListSwapsByRecipientResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsByRecipientResponse()..mergeFromBuffer(data, registry);
  factory ListSwapsByRecipientResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSwapsByRecipientResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSwapsByRecipientResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ListSwapsByRecipientResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsByRecipientResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSwapsByRecipientResponse copyWith(void Function(ListSwapsByRecipientResponse) updates) =>
      super.copyWith((message) => updates(message as ListSwapsByRecipientResponse)) as ListSwapsByRecipientResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSwapsByRecipientResponse() / ListSwapsByRecipientResponse.new instead')
  static ListSwapsByRecipientResponse create() => ListSwapsByRecipientResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSwapsByRecipientResponse._();
  @$core.override
  ListSwapsByRecipientResponse createEmptyInstance() => ListSwapsByRecipientResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSwapsByRecipientResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSwapsByRecipientResponse>(ListSwapsByRecipientResponse.$_createMessage);
  static ListSwapsByRecipientResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapsJson() => $_clearField(1);
}

class UpdateSwapL1TxidRequest extends $pb.GeneratedMessage {
  factory UpdateSwapL1TxidRequest({
    $core.String? swapId,
    $core.String? l1TxidHex,
    $core.int? confirmations,
  }) {
    final result = UpdateSwapL1TxidRequest._();
    if (swapId != null) result.swapId = swapId;
    if (l1TxidHex != null) result.l1TxidHex = l1TxidHex;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  UpdateSwapL1TxidRequest._();

  factory UpdateSwapL1TxidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSwapL1TxidRequest()..mergeFromBuffer(data, registry);
  factory UpdateSwapL1TxidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSwapL1TxidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSwapL1TxidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: UpdateSwapL1TxidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'swapId')
    ..aOS(2, _omitFieldNames ? '' : 'l1TxidHex')
    ..aI(3, _omitFieldNames ? '' : 'confirmations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSwapL1TxidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSwapL1TxidRequest copyWith(void Function(UpdateSwapL1TxidRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSwapL1TxidRequest)) as UpdateSwapL1TxidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateSwapL1TxidRequest() / UpdateSwapL1TxidRequest.new instead')
  static UpdateSwapL1TxidRequest create() => UpdateSwapL1TxidRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateSwapL1TxidRequest._();
  @$core.override
  UpdateSwapL1TxidRequest createEmptyInstance() => UpdateSwapL1TxidRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSwapL1TxidRequest>(UpdateSwapL1TxidRequest.$_createMessage);
  static UpdateSwapL1TxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get swapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set swapId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSwapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSwapId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get l1TxidHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set l1TxidHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1TxidHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1TxidHex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => $_clearField(3);
}

class UpdateSwapL1TxidResponse extends $pb.GeneratedMessage {
  factory UpdateSwapL1TxidResponse() => UpdateSwapL1TxidResponse._();

  UpdateSwapL1TxidResponse._();

  factory UpdateSwapL1TxidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSwapL1TxidResponse()..mergeFromBuffer(data, registry);
  factory UpdateSwapL1TxidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSwapL1TxidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSwapL1TxidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: UpdateSwapL1TxidResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSwapL1TxidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSwapL1TxidResponse copyWith(void Function(UpdateSwapL1TxidResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateSwapL1TxidResponse)) as UpdateSwapL1TxidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateSwapL1TxidResponse() / UpdateSwapL1TxidResponse.new instead')
  static UpdateSwapL1TxidResponse create() => UpdateSwapL1TxidResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateSwapL1TxidResponse._();
  @$core.override
  UpdateSwapL1TxidResponse createEmptyInstance() => UpdateSwapL1TxidResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateSwapL1TxidResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSwapL1TxidResponse>(UpdateSwapL1TxidResponse.$_createMessage);
  static UpdateSwapL1TxidResponse? _defaultInstance;
}

class ReconstructSwapsRequest extends $pb.GeneratedMessage {
  factory ReconstructSwapsRequest() => ReconstructSwapsRequest._();

  ReconstructSwapsRequest._();

  factory ReconstructSwapsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconstructSwapsRequest()..mergeFromBuffer(data, registry);
  factory ReconstructSwapsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconstructSwapsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconstructSwapsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ReconstructSwapsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconstructSwapsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconstructSwapsRequest copyWith(void Function(ReconstructSwapsRequest) updates) =>
      super.copyWith((message) => updates(message as ReconstructSwapsRequest)) as ReconstructSwapsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReconstructSwapsRequest() / ReconstructSwapsRequest.new instead')
  static ReconstructSwapsRequest create() => ReconstructSwapsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReconstructSwapsRequest._();
  @$core.override
  ReconstructSwapsRequest createEmptyInstance() => ReconstructSwapsRequest._();
  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconstructSwapsRequest>(ReconstructSwapsRequest.$_createMessage);
  static ReconstructSwapsRequest? _defaultInstance;
}

class ReconstructSwapsResponse extends $pb.GeneratedMessage {
  factory ReconstructSwapsResponse({
    $fixnum.Int64? count,
  }) {
    final result = ReconstructSwapsResponse._();
    if (count != null) result.count = count;
    return result;
  }

  ReconstructSwapsResponse._();

  factory ReconstructSwapsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconstructSwapsResponse()..mergeFromBuffer(data, registry);
  factory ReconstructSwapsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconstructSwapsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconstructSwapsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coinshift.v1'),
      createEmptyInstance: ReconstructSwapsResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconstructSwapsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconstructSwapsResponse copyWith(void Function(ReconstructSwapsResponse) updates) =>
      super.copyWith((message) => updates(message as ReconstructSwapsResponse)) as ReconstructSwapsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReconstructSwapsResponse() / ReconstructSwapsResponse.new instead')
  static ReconstructSwapsResponse create() => ReconstructSwapsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReconstructSwapsResponse._();
  @$core.override
  ReconstructSwapsResponse createEmptyInstance() => ReconstructSwapsResponse._();
  @$core.pragma('dart2js:noInline')
  static ReconstructSwapsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconstructSwapsResponse>(ReconstructSwapsResponse.$_createMessage);
  static ReconstructSwapsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class CoinShiftServiceApi {
  final $pb.RpcClient _client;

  CoinShiftServiceApi(this._client);

  /// Get wallet balance (total and available).
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'CoinShiftService', 'GetBalance', request, GetBalanceResponse());

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'CoinShiftService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Stop the coinshift node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'CoinShiftService', 'Stop', request, StopResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'CoinShiftService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Withdraw to mainchain.
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
      _client.invoke<WithdrawResponse>(ctx, 'CoinShiftService', 'Withdraw', request, WithdrawResponse());

  /// Transfer within sidechain.
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
      _client.invoke<TransferResponse>(ctx, 'CoinShiftService', 'Transfer', request, TransferResponse());

  /// Get total sidechain wealth in sats.
  $async.Future<GetSidechainWealthResponse> getSidechainWealth(
          $pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
      _client.invoke<GetSidechainWealthResponse>(
          ctx, 'CoinShiftService', 'GetSidechainWealth', request, GetSidechainWealthResponse());

  /// Create a deposit transaction.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
      _client.invoke<CreateDepositResponse>(ctx, 'CoinShiftService', 'CreateDeposit', request, CreateDepositResponse());

  /// Get pending withdrawal bundle.
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
          $pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
      _client.invoke<GetPendingWithdrawalBundleResponse>(
          ctx, 'CoinShiftService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse());

  /// Connect to a peer.
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
      _client.invoke<ConnectPeerResponse>(ctx, 'CoinShiftService', 'ConnectPeer', request, ConnectPeerResponse());

  /// Forget a peer.
  $async.Future<ForgetPeerResponse> forgetPeer($pb.ClientContext? ctx, ForgetPeerRequest request) =>
      _client.invoke<ForgetPeerResponse>(ctx, 'CoinShiftService', 'ForgetPeer', request, ForgetPeerResponse());

  /// List connected peers.
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
      _client.invoke<ListPeersResponse>(ctx, 'CoinShiftService', 'ListPeers', request, ListPeersResponse());

  /// Mine a block.
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
      _client.invoke<MineResponse>(ctx, 'CoinShiftService', 'Mine', request, MineResponse());

  /// Get block by hash.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'CoinShiftService', 'GetBlock', request, GetBlockResponse());

  /// Get best mainchain block hash.
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
          $pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
      _client.invoke<GetBestMainchainBlockHashResponse>(
          ctx, 'CoinShiftService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse());

  /// Get best sidechain block hash.
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
          $pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
      _client.invoke<GetBestSidechainBlockHashResponse>(
          ctx, 'CoinShiftService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse());

  /// Get BMM inclusions for a block.
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
      _client.invoke<GetBmmInclusionsResponse>(
          ctx, 'CoinShiftService', 'GetBmmInclusions', request, GetBmmInclusionsResponse());

  /// Get wallet UTXOs.
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) => _client
      .invoke<GetWalletUtxosResponse>(ctx, 'CoinShiftService', 'GetWalletUtxos', request, GetWalletUtxosResponse());

  /// List all UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'CoinShiftService', 'ListUtxos', request, ListUtxosResponse());

  /// Remove transaction from mempool.
  $async.Future<RemoveFromMempoolResponse> removeFromMempool(
          $pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
      _client.invoke<RemoveFromMempoolResponse>(
          ctx, 'CoinShiftService', 'RemoveFromMempool', request, RemoveFromMempoolResponse());

  /// Get latest failed withdrawal bundle height.
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
          $pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
      _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'CoinShiftService',
          'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse());

  /// Generate a new mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'CoinShiftService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// Set seed from mnemonic.
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic(
          $pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
      _client.invoke<SetSeedFromMnemonicResponse>(
          ctx, 'CoinShiftService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse());

  /// Raw JSON-RPC passthrough for debug console.
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
      _client.invoke<CallRawResponse>(ctx, 'CoinShiftService', 'CallRaw', request, CallRawResponse());

  /// Get wallet addresses.
  $async.Future<GetWalletAddressesResponse> getWalletAddresses(
          $pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
      _client.invoke<GetWalletAddressesResponse>(
          ctx, 'CoinShiftService', 'GetWalletAddresses', request, GetWalletAddressesResponse());

  /// Get OpenAPI schema.
  $async.Future<OpenapiSchemaResponse> openapiSchema($pb.ClientContext? ctx, OpenapiSchemaRequest request) =>
      _client.invoke<OpenapiSchemaResponse>(ctx, 'CoinShiftService', 'OpenapiSchema', request, OpenapiSchemaResponse());

  /// Create a swap (L2 to L1).
  $async.Future<CreateSwapResponse> createSwap($pb.ClientContext? ctx, CreateSwapRequest request) =>
      _client.invoke<CreateSwapResponse>(ctx, 'CoinShiftService', 'CreateSwap', request, CreateSwapResponse());

  /// Claim a swap.
  $async.Future<ClaimSwapResponse> claimSwap($pb.ClientContext? ctx, ClaimSwapRequest request) =>
      _client.invoke<ClaimSwapResponse>(ctx, 'CoinShiftService', 'ClaimSwap', request, ClaimSwapResponse());

  /// Get swap status.
  $async.Future<GetSwapStatusResponse> getSwapStatus($pb.ClientContext? ctx, GetSwapStatusRequest request) =>
      _client.invoke<GetSwapStatusResponse>(ctx, 'CoinShiftService', 'GetSwapStatus', request, GetSwapStatusResponse());

  /// List all swaps.
  $async.Future<ListSwapsResponse> listSwaps($pb.ClientContext? ctx, ListSwapsRequest request) =>
      _client.invoke<ListSwapsResponse>(ctx, 'CoinShiftService', 'ListSwaps', request, ListSwapsResponse());

  /// List swaps for a specific recipient.
  $async.Future<ListSwapsByRecipientResponse> listSwapsByRecipient(
          $pb.ClientContext? ctx, ListSwapsByRecipientRequest request) =>
      _client.invoke<ListSwapsByRecipientResponse>(
          ctx, 'CoinShiftService', 'ListSwapsByRecipient', request, ListSwapsByRecipientResponse());

  /// Update swap L1 transaction ID.
  $async.Future<UpdateSwapL1TxidResponse> updateSwapL1Txid($pb.ClientContext? ctx, UpdateSwapL1TxidRequest request) =>
      _client.invoke<UpdateSwapL1TxidResponse>(
          ctx, 'CoinShiftService', 'UpdateSwapL1Txid', request, UpdateSwapL1TxidResponse());

  /// Reconstruct all swaps from blockchain.
  $async.Future<ReconstructSwapsResponse> reconstructSwaps($pb.ClientContext? ctx, ReconstructSwapsRequest request) =>
      _client.invoke<ReconstructSwapsResponse>(
          ctx, 'CoinShiftService', 'ReconstructSwaps', request, ReconstructSwapsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
