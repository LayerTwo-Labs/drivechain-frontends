// This is a generated file - do not edit.
//
// Generated from bitassets/v1/bitassets.proto.

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
    $core.String? memo,
  }) {
    final result = TransferRequest._();
    if (address != null) result.address = address;
    if (amountSats != null) result.amountSats = amountSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (memo != null) result.memo = memo;
    return result;
  }

  TransferRequest._();

  factory TransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferRequest()..mergeFromBuffer(data, registry);
  factory TransferRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: TransferRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
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

  @$pb.TagNumber(4)
  $core.String get memo => $_getSZ(3);
  @$pb.TagNumber(4)
  set memo($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemo() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemo() => $_clearField(4);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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

class GetBitAssetDataRequest extends $pb.GeneratedMessage {
  factory GetBitAssetDataRequest({
    $core.String? assetId,
  }) {
    final result = GetBitAssetDataRequest._();
    if (assetId != null) result.assetId = assetId;
    return result;
  }

  GetBitAssetDataRequest._();

  factory GetBitAssetDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitAssetDataRequest()..mergeFromBuffer(data, registry);
  factory GetBitAssetDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitAssetDataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitAssetDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetBitAssetDataRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'assetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitAssetDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitAssetDataRequest copyWith(void Function(GetBitAssetDataRequest) updates) =>
      super.copyWith((message) => updates(message as GetBitAssetDataRequest)) as GetBitAssetDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitAssetDataRequest() / GetBitAssetDataRequest.new instead')
  static GetBitAssetDataRequest create() => GetBitAssetDataRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBitAssetDataRequest._();
  @$core.override
  GetBitAssetDataRequest createEmptyInstance() => GetBitAssetDataRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitAssetDataRequest>(GetBitAssetDataRequest.$_createMessage);
  static GetBitAssetDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => $_clearField(1);
}

class GetBitAssetDataResponse extends $pb.GeneratedMessage {
  factory GetBitAssetDataResponse({
    $core.String? dataJson,
  }) {
    final result = GetBitAssetDataResponse._();
    if (dataJson != null) result.dataJson = dataJson;
    return result;
  }

  GetBitAssetDataResponse._();

  factory GetBitAssetDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitAssetDataResponse()..mergeFromBuffer(data, registry);
  factory GetBitAssetDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitAssetDataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitAssetDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetBitAssetDataResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitAssetDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitAssetDataResponse copyWith(void Function(GetBitAssetDataResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitAssetDataResponse)) as GetBitAssetDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitAssetDataResponse() / GetBitAssetDataResponse.new instead')
  static GetBitAssetDataResponse create() => GetBitAssetDataResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBitAssetDataResponse._();
  @$core.override
  GetBitAssetDataResponse createEmptyInstance() => GetBitAssetDataResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBitAssetDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitAssetDataResponse>(GetBitAssetDataResponse.$_createMessage);
  static GetBitAssetDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataJson() => $_clearField(1);
}

class ListBitAssetsRequest extends $pb.GeneratedMessage {
  factory ListBitAssetsRequest() => ListBitAssetsRequest._();

  ListBitAssetsRequest._();

  factory ListBitAssetsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitAssetsRequest()..mergeFromBuffer(data, registry);
  factory ListBitAssetsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitAssetsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitAssetsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: ListBitAssetsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitAssetsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitAssetsRequest copyWith(void Function(ListBitAssetsRequest) updates) =>
      super.copyWith((message) => updates(message as ListBitAssetsRequest)) as ListBitAssetsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBitAssetsRequest() / ListBitAssetsRequest.new instead')
  static ListBitAssetsRequest create() => ListBitAssetsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBitAssetsRequest._();
  @$core.override
  ListBitAssetsRequest createEmptyInstance() => ListBitAssetsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBitAssetsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBitAssetsRequest>(ListBitAssetsRequest.$_createMessage);
  static ListBitAssetsRequest? _defaultInstance;
}

class ListBitAssetsResponse extends $pb.GeneratedMessage {
  factory ListBitAssetsResponse({
    $core.String? bitassetsJson,
  }) {
    final result = ListBitAssetsResponse._();
    if (bitassetsJson != null) result.bitassetsJson = bitassetsJson;
    return result;
  }

  ListBitAssetsResponse._();

  factory ListBitAssetsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitAssetsResponse()..mergeFromBuffer(data, registry);
  factory ListBitAssetsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitAssetsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitAssetsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: ListBitAssetsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bitassetsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitAssetsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitAssetsResponse copyWith(void Function(ListBitAssetsResponse) updates) =>
      super.copyWith((message) => updates(message as ListBitAssetsResponse)) as ListBitAssetsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBitAssetsResponse() / ListBitAssetsResponse.new instead')
  static ListBitAssetsResponse create() => ListBitAssetsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBitAssetsResponse._();
  @$core.override
  ListBitAssetsResponse createEmptyInstance() => ListBitAssetsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBitAssetsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBitAssetsResponse>(ListBitAssetsResponse.$_createMessage);
  static ListBitAssetsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bitassetsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bitassetsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBitassetsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitassetsJson() => $_clearField(1);
}

class RegisterBitAssetRequest extends $pb.GeneratedMessage {
  factory RegisterBitAssetRequest({
    $core.String? plaintextName,
    $fixnum.Int64? initialSupply,
    $core.String? dataJson,
  }) {
    final result = RegisterBitAssetRequest._();
    if (plaintextName != null) result.plaintextName = plaintextName;
    if (initialSupply != null) result.initialSupply = initialSupply;
    if (dataJson != null) result.dataJson = dataJson;
    return result;
  }

  RegisterBitAssetRequest._();

  factory RegisterBitAssetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitAssetRequest()..mergeFromBuffer(data, registry);
  factory RegisterBitAssetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitAssetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitAssetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: RegisterBitAssetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'plaintextName')
    ..aInt64(2, _omitFieldNames ? '' : 'initialSupply')
    ..aOS(3, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitAssetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitAssetRequest copyWith(void Function(RegisterBitAssetRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterBitAssetRequest)) as RegisterBitAssetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterBitAssetRequest() / RegisterBitAssetRequest.new instead')
  static RegisterBitAssetRequest create() => RegisterBitAssetRequest._();
  static $pb.GeneratedMessage $_createMessage() => RegisterBitAssetRequest._();
  @$core.override
  RegisterBitAssetRequest createEmptyInstance() => RegisterBitAssetRequest._();
  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterBitAssetRequest>(RegisterBitAssetRequest.$_createMessage);
  static RegisterBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plaintextName => $_getSZ(0);
  @$pb.TagNumber(1)
  set plaintextName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlaintextName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlaintextName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get initialSupply => $_getI64(1);
  @$pb.TagNumber(2)
  set initialSupply($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInitialSupply() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitialSupply() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dataJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set dataJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDataJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataJson() => $_clearField(3);
}

class RegisterBitAssetResponse extends $pb.GeneratedMessage {
  factory RegisterBitAssetResponse({
    $core.String? txid,
  }) {
    final result = RegisterBitAssetResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  RegisterBitAssetResponse._();

  factory RegisterBitAssetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitAssetResponse()..mergeFromBuffer(data, registry);
  factory RegisterBitAssetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitAssetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitAssetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: RegisterBitAssetResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitAssetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitAssetResponse copyWith(void Function(RegisterBitAssetResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterBitAssetResponse)) as RegisterBitAssetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterBitAssetResponse() / RegisterBitAssetResponse.new instead')
  static RegisterBitAssetResponse create() => RegisterBitAssetResponse._();
  static $pb.GeneratedMessage $_createMessage() => RegisterBitAssetResponse._();
  @$core.override
  RegisterBitAssetResponse createEmptyInstance() => RegisterBitAssetResponse._();
  @$core.pragma('dart2js:noInline')
  static RegisterBitAssetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterBitAssetResponse>(RegisterBitAssetResponse.$_createMessage);
  static RegisterBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class ReserveBitAssetRequest extends $pb.GeneratedMessage {
  factory ReserveBitAssetRequest({
    $core.String? name,
  }) {
    final result = ReserveBitAssetRequest._();
    if (name != null) result.name = name;
    return result;
  }

  ReserveBitAssetRequest._();

  factory ReserveBitAssetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitAssetRequest()..mergeFromBuffer(data, registry);
  factory ReserveBitAssetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitAssetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitAssetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: ReserveBitAssetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitAssetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitAssetRequest copyWith(void Function(ReserveBitAssetRequest) updates) =>
      super.copyWith((message) => updates(message as ReserveBitAssetRequest)) as ReserveBitAssetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveBitAssetRequest() / ReserveBitAssetRequest.new instead')
  static ReserveBitAssetRequest create() => ReserveBitAssetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReserveBitAssetRequest._();
  @$core.override
  ReserveBitAssetRequest createEmptyInstance() => ReserveBitAssetRequest._();
  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReserveBitAssetRequest>(ReserveBitAssetRequest.$_createMessage);
  static ReserveBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class ReserveBitAssetResponse extends $pb.GeneratedMessage {
  factory ReserveBitAssetResponse({
    $core.String? txid,
  }) {
    final result = ReserveBitAssetResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  ReserveBitAssetResponse._();

  factory ReserveBitAssetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitAssetResponse()..mergeFromBuffer(data, registry);
  factory ReserveBitAssetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitAssetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitAssetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: ReserveBitAssetResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitAssetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitAssetResponse copyWith(void Function(ReserveBitAssetResponse) updates) =>
      super.copyWith((message) => updates(message as ReserveBitAssetResponse)) as ReserveBitAssetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveBitAssetResponse() / ReserveBitAssetResponse.new instead')
  static ReserveBitAssetResponse create() => ReserveBitAssetResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReserveBitAssetResponse._();
  @$core.override
  ReserveBitAssetResponse createEmptyInstance() => ReserveBitAssetResponse._();
  @$core.pragma('dart2js:noInline')
  static ReserveBitAssetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReserveBitAssetResponse>(ReserveBitAssetResponse.$_createMessage);
  static ReserveBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class TransferBitAssetRequest extends $pb.GeneratedMessage {
  factory TransferBitAssetRequest({
    $core.String? assetId,
    $core.String? dest,
    $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
  }) {
    final result = TransferBitAssetRequest._();
    if (assetId != null) result.assetId = assetId;
    if (dest != null) result.dest = dest;
    if (amount != null) result.amount = amount;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  TransferBitAssetRequest._();

  factory TransferBitAssetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferBitAssetRequest()..mergeFromBuffer(data, registry);
  factory TransferBitAssetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferBitAssetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferBitAssetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: TransferBitAssetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'assetId')
    ..aOS(2, _omitFieldNames ? '' : 'dest')
    ..aInt64(3, _omitFieldNames ? '' : 'amount')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBitAssetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBitAssetRequest copyWith(void Function(TransferBitAssetRequest) updates) =>
      super.copyWith((message) => updates(message as TransferBitAssetRequest)) as TransferBitAssetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferBitAssetRequest() / TransferBitAssetRequest.new instead')
  static TransferBitAssetRequest create() => TransferBitAssetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TransferBitAssetRequest._();
  @$core.override
  TransferBitAssetRequest createEmptyInstance() => TransferBitAssetRequest._();
  @$core.pragma('dart2js:noInline')
  static TransferBitAssetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferBitAssetRequest>(TransferBitAssetRequest.$_createMessage);
  static TransferBitAssetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dest => $_getSZ(1);
  @$pb.TagNumber(2)
  set dest($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDest() => $_has(1);
  @$pb.TagNumber(2)
  void clearDest() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);
}

class TransferBitAssetResponse extends $pb.GeneratedMessage {
  factory TransferBitAssetResponse({
    $core.String? txid,
  }) {
    final result = TransferBitAssetResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  TransferBitAssetResponse._();

  factory TransferBitAssetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferBitAssetResponse()..mergeFromBuffer(data, registry);
  factory TransferBitAssetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferBitAssetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferBitAssetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: TransferBitAssetResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBitAssetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBitAssetResponse copyWith(void Function(TransferBitAssetResponse) updates) =>
      super.copyWith((message) => updates(message as TransferBitAssetResponse)) as TransferBitAssetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferBitAssetResponse() / TransferBitAssetResponse.new instead')
  static TransferBitAssetResponse create() => TransferBitAssetResponse._();
  static $pb.GeneratedMessage $_createMessage() => TransferBitAssetResponse._();
  @$core.override
  TransferBitAssetResponse createEmptyInstance() => TransferBitAssetResponse._();
  @$core.pragma('dart2js:noInline')
  static TransferBitAssetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferBitAssetResponse>(TransferBitAssetResponse.$_createMessage);
  static TransferBitAssetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetNewEncryptionKeyRequest extends $pb.GeneratedMessage {
  factory GetNewEncryptionKeyRequest() => GetNewEncryptionKeyRequest._();

  GetNewEncryptionKeyRequest._();

  factory GetNewEncryptionKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewEncryptionKeyRequest()..mergeFromBuffer(data, registry);
  factory GetNewEncryptionKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewEncryptionKeyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetNewEncryptionKeyRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewEncryptionKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewEncryptionKeyRequest copyWith(void Function(GetNewEncryptionKeyRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewEncryptionKeyRequest)) as GetNewEncryptionKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewEncryptionKeyRequest() / GetNewEncryptionKeyRequest.new instead')
  static GetNewEncryptionKeyRequest create() => GetNewEncryptionKeyRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewEncryptionKeyRequest._();
  @$core.override
  GetNewEncryptionKeyRequest createEmptyInstance() => GetNewEncryptionKeyRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewEncryptionKeyRequest>(GetNewEncryptionKeyRequest.$_createMessage);
  static GetNewEncryptionKeyRequest? _defaultInstance;
}

class GetNewEncryptionKeyResponse extends $pb.GeneratedMessage {
  factory GetNewEncryptionKeyResponse({
    $core.String? key,
  }) {
    final result = GetNewEncryptionKeyResponse._();
    if (key != null) result.key = key;
    return result;
  }

  GetNewEncryptionKeyResponse._();

  factory GetNewEncryptionKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewEncryptionKeyResponse()..mergeFromBuffer(data, registry);
  factory GetNewEncryptionKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewEncryptionKeyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewEncryptionKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetNewEncryptionKeyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewEncryptionKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewEncryptionKeyResponse copyWith(void Function(GetNewEncryptionKeyResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewEncryptionKeyResponse)) as GetNewEncryptionKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewEncryptionKeyResponse() / GetNewEncryptionKeyResponse.new instead')
  static GetNewEncryptionKeyResponse create() => GetNewEncryptionKeyResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewEncryptionKeyResponse._();
  @$core.override
  GetNewEncryptionKeyResponse createEmptyInstance() => GetNewEncryptionKeyResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewEncryptionKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewEncryptionKeyResponse>(GetNewEncryptionKeyResponse.$_createMessage);
  static GetNewEncryptionKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
}

class GetNewVerifyingKeyRequest extends $pb.GeneratedMessage {
  factory GetNewVerifyingKeyRequest() => GetNewVerifyingKeyRequest._();

  GetNewVerifyingKeyRequest._();

  factory GetNewVerifyingKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewVerifyingKeyRequest()..mergeFromBuffer(data, registry);
  factory GetNewVerifyingKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewVerifyingKeyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetNewVerifyingKeyRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewVerifyingKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewVerifyingKeyRequest copyWith(void Function(GetNewVerifyingKeyRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewVerifyingKeyRequest)) as GetNewVerifyingKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewVerifyingKeyRequest() / GetNewVerifyingKeyRequest.new instead')
  static GetNewVerifyingKeyRequest create() => GetNewVerifyingKeyRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewVerifyingKeyRequest._();
  @$core.override
  GetNewVerifyingKeyRequest createEmptyInstance() => GetNewVerifyingKeyRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewVerifyingKeyRequest>(GetNewVerifyingKeyRequest.$_createMessage);
  static GetNewVerifyingKeyRequest? _defaultInstance;
}

class GetNewVerifyingKeyResponse extends $pb.GeneratedMessage {
  factory GetNewVerifyingKeyResponse({
    $core.String? key,
  }) {
    final result = GetNewVerifyingKeyResponse._();
    if (key != null) result.key = key;
    return result;
  }

  GetNewVerifyingKeyResponse._();

  factory GetNewVerifyingKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewVerifyingKeyResponse()..mergeFromBuffer(data, registry);
  factory GetNewVerifyingKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewVerifyingKeyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewVerifyingKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetNewVerifyingKeyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewVerifyingKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewVerifyingKeyResponse copyWith(void Function(GetNewVerifyingKeyResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewVerifyingKeyResponse)) as GetNewVerifyingKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewVerifyingKeyResponse() / GetNewVerifyingKeyResponse.new instead')
  static GetNewVerifyingKeyResponse create() => GetNewVerifyingKeyResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewVerifyingKeyResponse._();
  @$core.override
  GetNewVerifyingKeyResponse createEmptyInstance() => GetNewVerifyingKeyResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewVerifyingKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewVerifyingKeyResponse>(GetNewVerifyingKeyResponse.$_createMessage);
  static GetNewVerifyingKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
}

class DecryptMsgRequest extends $pb.GeneratedMessage {
  factory DecryptMsgRequest({
    $core.String? ciphertext,
    $core.String? encryptionPubkey,
  }) {
    final result = DecryptMsgRequest._();
    if (ciphertext != null) result.ciphertext = ciphertext;
    if (encryptionPubkey != null) result.encryptionPubkey = encryptionPubkey;
    return result;
  }

  DecryptMsgRequest._();

  factory DecryptMsgRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecryptMsgRequest()..mergeFromBuffer(data, registry);
  factory DecryptMsgRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecryptMsgRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DecryptMsgRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'ciphertext')
    ..aOS(2, _omitFieldNames ? '' : 'encryptionPubkey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecryptMsgRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecryptMsgRequest copyWith(void Function(DecryptMsgRequest) updates) =>
      super.copyWith((message) => updates(message as DecryptMsgRequest)) as DecryptMsgRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecryptMsgRequest() / DecryptMsgRequest.new instead')
  static DecryptMsgRequest create() => DecryptMsgRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecryptMsgRequest._();
  @$core.override
  DecryptMsgRequest createEmptyInstance() => DecryptMsgRequest._();
  @$core.pragma('dart2js:noInline')
  static DecryptMsgRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecryptMsgRequest>(DecryptMsgRequest.$_createMessage);
  static DecryptMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ciphertext => $_getSZ(0);
  @$pb.TagNumber(1)
  set ciphertext($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCiphertext() => $_has(0);
  @$pb.TagNumber(1)
  void clearCiphertext() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptionPubkey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptionPubkey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptionPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionPubkey() => $_clearField(2);
}

class DecryptMsgResponse extends $pb.GeneratedMessage {
  factory DecryptMsgResponse({
    $core.String? plaintext,
  }) {
    final result = DecryptMsgResponse._();
    if (plaintext != null) result.plaintext = plaintext;
    return result;
  }

  DecryptMsgResponse._();

  factory DecryptMsgResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecryptMsgResponse()..mergeFromBuffer(data, registry);
  factory DecryptMsgResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecryptMsgResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecryptMsgResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DecryptMsgResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'plaintext')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecryptMsgResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecryptMsgResponse copyWith(void Function(DecryptMsgResponse) updates) =>
      super.copyWith((message) => updates(message as DecryptMsgResponse)) as DecryptMsgResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecryptMsgResponse() / DecryptMsgResponse.new instead')
  static DecryptMsgResponse create() => DecryptMsgResponse._();
  static $pb.GeneratedMessage $_createMessage() => DecryptMsgResponse._();
  @$core.override
  DecryptMsgResponse createEmptyInstance() => DecryptMsgResponse._();
  @$core.pragma('dart2js:noInline')
  static DecryptMsgResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecryptMsgResponse>(DecryptMsgResponse.$_createMessage);
  static DecryptMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plaintext => $_getSZ(0);
  @$pb.TagNumber(1)
  set plaintext($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlaintext() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlaintext() => $_clearField(1);
}

class EncryptMsgRequest extends $pb.GeneratedMessage {
  factory EncryptMsgRequest({
    $core.String? msg,
    $core.String? encryptionPubkey,
  }) {
    final result = EncryptMsgRequest._();
    if (msg != null) result.msg = msg;
    if (encryptionPubkey != null) result.encryptionPubkey = encryptionPubkey;
    return result;
  }

  EncryptMsgRequest._();

  factory EncryptMsgRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptMsgRequest()..mergeFromBuffer(data, registry);
  factory EncryptMsgRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptMsgRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: EncryptMsgRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'encryptionPubkey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptMsgRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptMsgRequest copyWith(void Function(EncryptMsgRequest) updates) =>
      super.copyWith((message) => updates(message as EncryptMsgRequest)) as EncryptMsgRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncryptMsgRequest() / EncryptMsgRequest.new instead')
  static EncryptMsgRequest create() => EncryptMsgRequest._();
  static $pb.GeneratedMessage $_createMessage() => EncryptMsgRequest._();
  @$core.override
  EncryptMsgRequest createEmptyInstance() => EncryptMsgRequest._();
  @$core.pragma('dart2js:noInline')
  static EncryptMsgRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptMsgRequest>(EncryptMsgRequest.$_createMessage);
  static EncryptMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptionPubkey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptionPubkey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptionPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionPubkey() => $_clearField(2);
}

class EncryptMsgResponse extends $pb.GeneratedMessage {
  factory EncryptMsgResponse({
    $core.String? ciphertext,
  }) {
    final result = EncryptMsgResponse._();
    if (ciphertext != null) result.ciphertext = ciphertext;
    return result;
  }

  EncryptMsgResponse._();

  factory EncryptMsgResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptMsgResponse()..mergeFromBuffer(data, registry);
  factory EncryptMsgResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptMsgResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptMsgResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: EncryptMsgResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'ciphertext')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptMsgResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptMsgResponse copyWith(void Function(EncryptMsgResponse) updates) =>
      super.copyWith((message) => updates(message as EncryptMsgResponse)) as EncryptMsgResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncryptMsgResponse() / EncryptMsgResponse.new instead')
  static EncryptMsgResponse create() => EncryptMsgResponse._();
  static $pb.GeneratedMessage $_createMessage() => EncryptMsgResponse._();
  @$core.override
  EncryptMsgResponse createEmptyInstance() => EncryptMsgResponse._();
  @$core.pragma('dart2js:noInline')
  static EncryptMsgResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptMsgResponse>(EncryptMsgResponse.$_createMessage);
  static EncryptMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ciphertext => $_getSZ(0);
  @$pb.TagNumber(1)
  set ciphertext($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCiphertext() => $_has(0);
  @$pb.TagNumber(1)
  void clearCiphertext() => $_clearField(1);
}

class SignArbitraryMsgRequest extends $pb.GeneratedMessage {
  factory SignArbitraryMsgRequest({
    $core.String? msg,
    $core.String? verifyingKey,
  }) {
    final result = SignArbitraryMsgRequest._();
    if (msg != null) result.msg = msg;
    if (verifyingKey != null) result.verifyingKey = verifyingKey;
    return result;
  }

  SignArbitraryMsgRequest._();

  factory SignArbitraryMsgRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgRequest()..mergeFromBuffer(data, registry);
  factory SignArbitraryMsgRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: SignArbitraryMsgRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'verifyingKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgRequest copyWith(void Function(SignArbitraryMsgRequest) updates) =>
      super.copyWith((message) => updates(message as SignArbitraryMsgRequest)) as SignArbitraryMsgRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignArbitraryMsgRequest() / SignArbitraryMsgRequest.new instead')
  static SignArbitraryMsgRequest create() => SignArbitraryMsgRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignArbitraryMsgRequest._();
  @$core.override
  SignArbitraryMsgRequest createEmptyInstance() => SignArbitraryMsgRequest._();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgRequest>(SignArbitraryMsgRequest.$_createMessage);
  static SignArbitraryMsgRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get verifyingKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set verifyingKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVerifyingKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerifyingKey() => $_clearField(2);
}

class SignArbitraryMsgResponse extends $pb.GeneratedMessage {
  factory SignArbitraryMsgResponse({
    $core.String? signature,
  }) {
    final result = SignArbitraryMsgResponse._();
    if (signature != null) result.signature = signature;
    return result;
  }

  SignArbitraryMsgResponse._();

  factory SignArbitraryMsgResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgResponse()..mergeFromBuffer(data, registry);
  factory SignArbitraryMsgResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: SignArbitraryMsgResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgResponse copyWith(void Function(SignArbitraryMsgResponse) updates) =>
      super.copyWith((message) => updates(message as SignArbitraryMsgResponse)) as SignArbitraryMsgResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignArbitraryMsgResponse() / SignArbitraryMsgResponse.new instead')
  static SignArbitraryMsgResponse create() => SignArbitraryMsgResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignArbitraryMsgResponse._();
  @$core.override
  SignArbitraryMsgResponse createEmptyInstance() => SignArbitraryMsgResponse._();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgResponse>(SignArbitraryMsgResponse.$_createMessage);
  static SignArbitraryMsgResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);
}

class SignArbitraryMsgAsAddrRequest extends $pb.GeneratedMessage {
  factory SignArbitraryMsgAsAddrRequest({
    $core.String? msg,
    $core.String? address,
  }) {
    final result = SignArbitraryMsgAsAddrRequest._();
    if (msg != null) result.msg = msg;
    if (address != null) result.address = address;
    return result;
  }

  SignArbitraryMsgAsAddrRequest._();

  factory SignArbitraryMsgAsAddrRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgAsAddrRequest()..mergeFromBuffer(data, registry);
  factory SignArbitraryMsgAsAddrRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgAsAddrRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: SignArbitraryMsgAsAddrRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgAsAddrRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgAsAddrRequest copyWith(void Function(SignArbitraryMsgAsAddrRequest) updates) =>
      super.copyWith((message) => updates(message as SignArbitraryMsgAsAddrRequest)) as SignArbitraryMsgAsAddrRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignArbitraryMsgAsAddrRequest() / SignArbitraryMsgAsAddrRequest.new instead')
  static SignArbitraryMsgAsAddrRequest create() => SignArbitraryMsgAsAddrRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignArbitraryMsgAsAddrRequest._();
  @$core.override
  SignArbitraryMsgAsAddrRequest createEmptyInstance() => SignArbitraryMsgAsAddrRequest._();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgAsAddrRequest>(SignArbitraryMsgAsAddrRequest.$_createMessage);
  static SignArbitraryMsgAsAddrRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);
}

class SignArbitraryMsgAsAddrResponse extends $pb.GeneratedMessage {
  factory SignArbitraryMsgAsAddrResponse({
    $core.String? verifyingKey,
    $core.String? signature,
  }) {
    final result = SignArbitraryMsgAsAddrResponse._();
    if (verifyingKey != null) result.verifyingKey = verifyingKey;
    if (signature != null) result.signature = signature;
    return result;
  }

  SignArbitraryMsgAsAddrResponse._();

  factory SignArbitraryMsgAsAddrResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgAsAddrResponse()..mergeFromBuffer(data, registry);
  factory SignArbitraryMsgAsAddrResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignArbitraryMsgAsAddrResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignArbitraryMsgAsAddrResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: SignArbitraryMsgAsAddrResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'verifyingKey')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgAsAddrResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignArbitraryMsgAsAddrResponse copyWith(void Function(SignArbitraryMsgAsAddrResponse) updates) =>
      super.copyWith((message) => updates(message as SignArbitraryMsgAsAddrResponse)) as SignArbitraryMsgAsAddrResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignArbitraryMsgAsAddrResponse() / SignArbitraryMsgAsAddrResponse.new instead')
  static SignArbitraryMsgAsAddrResponse create() => SignArbitraryMsgAsAddrResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignArbitraryMsgAsAddrResponse._();
  @$core.override
  SignArbitraryMsgAsAddrResponse createEmptyInstance() => SignArbitraryMsgAsAddrResponse._();
  @$core.pragma('dart2js:noInline')
  static SignArbitraryMsgAsAddrResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignArbitraryMsgAsAddrResponse>(SignArbitraryMsgAsAddrResponse.$_createMessage);
  static SignArbitraryMsgAsAddrResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get verifyingKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set verifyingKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVerifyingKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerifyingKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get signature => $_getSZ(1);
  @$pb.TagNumber(2)
  set signature($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

class VerifySignatureRequest extends $pb.GeneratedMessage {
  factory VerifySignatureRequest({
    $core.String? msg,
    $core.String? signature,
    $core.String? verifyingKey,
  }) {
    final result = VerifySignatureRequest._();
    if (msg != null) result.msg = msg;
    if (signature != null) result.signature = signature;
    if (verifyingKey != null) result.verifyingKey = verifyingKey;
    return result;
  }

  VerifySignatureRequest._();

  factory VerifySignatureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifySignatureRequest()..mergeFromBuffer(data, registry);
  factory VerifySignatureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifySignatureRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: VerifySignatureRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..aOS(3, _omitFieldNames ? '' : 'verifyingKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifySignatureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifySignatureRequest copyWith(void Function(VerifySignatureRequest) updates) =>
      super.copyWith((message) => updates(message as VerifySignatureRequest)) as VerifySignatureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifySignatureRequest() / VerifySignatureRequest.new instead')
  static VerifySignatureRequest create() => VerifySignatureRequest._();
  static $pb.GeneratedMessage $_createMessage() => VerifySignatureRequest._();
  @$core.override
  VerifySignatureRequest createEmptyInstance() => VerifySignatureRequest._();
  @$core.pragma('dart2js:noInline')
  static VerifySignatureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifySignatureRequest>(VerifySignatureRequest.$_createMessage);
  static VerifySignatureRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get signature => $_getSZ(1);
  @$pb.TagNumber(2)
  set signature($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get verifyingKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set verifyingKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVerifyingKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerifyingKey() => $_clearField(3);
}

class VerifySignatureResponse extends $pb.GeneratedMessage {
  factory VerifySignatureResponse({
    $core.bool? valid,
  }) {
    final result = VerifySignatureResponse._();
    if (valid != null) result.valid = valid;
    return result;
  }

  VerifySignatureResponse._();

  factory VerifySignatureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifySignatureResponse()..mergeFromBuffer(data, registry);
  factory VerifySignatureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifySignatureResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifySignatureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: VerifySignatureResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifySignatureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifySignatureResponse copyWith(void Function(VerifySignatureResponse) updates) =>
      super.copyWith((message) => updates(message as VerifySignatureResponse)) as VerifySignatureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifySignatureResponse() / VerifySignatureResponse.new instead')
  static VerifySignatureResponse create() => VerifySignatureResponse._();
  static $pb.GeneratedMessage $_createMessage() => VerifySignatureResponse._();
  @$core.override
  VerifySignatureResponse createEmptyInstance() => VerifySignatureResponse._();
  @$core.pragma('dart2js:noInline')
  static VerifySignatureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifySignatureResponse>(VerifySignatureResponse.$_createMessage);
  static VerifySignatureResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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

class MyUnconfirmedUtxosRequest extends $pb.GeneratedMessage {
  factory MyUnconfirmedUtxosRequest() => MyUnconfirmedUtxosRequest._();

  MyUnconfirmedUtxosRequest._();

  factory MyUnconfirmedUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUnconfirmedUtxosRequest()..mergeFromBuffer(data, registry);
  factory MyUnconfirmedUtxosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUnconfirmedUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: MyUnconfirmedUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUnconfirmedUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUnconfirmedUtxosRequest copyWith(void Function(MyUnconfirmedUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as MyUnconfirmedUtxosRequest)) as MyUnconfirmedUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MyUnconfirmedUtxosRequest() / MyUnconfirmedUtxosRequest.new instead')
  static MyUnconfirmedUtxosRequest create() => MyUnconfirmedUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => MyUnconfirmedUtxosRequest._();
  @$core.override
  MyUnconfirmedUtxosRequest createEmptyInstance() => MyUnconfirmedUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MyUnconfirmedUtxosRequest>(MyUnconfirmedUtxosRequest.$_createMessage);
  static MyUnconfirmedUtxosRequest? _defaultInstance;
}

class MyUnconfirmedUtxosResponse extends $pb.GeneratedMessage {
  factory MyUnconfirmedUtxosResponse({
    $core.String? utxosJson,
  }) {
    final result = MyUnconfirmedUtxosResponse._();
    if (utxosJson != null) result.utxosJson = utxosJson;
    return result;
  }

  MyUnconfirmedUtxosResponse._();

  factory MyUnconfirmedUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUnconfirmedUtxosResponse()..mergeFromBuffer(data, registry);
  factory MyUnconfirmedUtxosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUnconfirmedUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUnconfirmedUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: MyUnconfirmedUtxosResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUnconfirmedUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUnconfirmedUtxosResponse copyWith(void Function(MyUnconfirmedUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as MyUnconfirmedUtxosResponse)) as MyUnconfirmedUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MyUnconfirmedUtxosResponse() / MyUnconfirmedUtxosResponse.new instead')
  static MyUnconfirmedUtxosResponse create() => MyUnconfirmedUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => MyUnconfirmedUtxosResponse._();
  @$core.override
  MyUnconfirmedUtxosResponse createEmptyInstance() => MyUnconfirmedUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static MyUnconfirmedUtxosResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MyUnconfirmedUtxosResponse>(MyUnconfirmedUtxosResponse.$_createMessage);
  static MyUnconfirmedUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utxosJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set utxosJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUtxosJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosJson() => $_clearField(1);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
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

class AmmBurnRequest extends $pb.GeneratedMessage {
  factory AmmBurnRequest({
    $core.String? asset0,
    $core.String? asset1,
    $fixnum.Int64? lpTokenAmount,
  }) {
    final result = AmmBurnRequest._();
    if (asset0 != null) result.asset0 = asset0;
    if (asset1 != null) result.asset1 = asset1;
    if (lpTokenAmount != null) result.lpTokenAmount = lpTokenAmount;
    return result;
  }

  AmmBurnRequest._();

  factory AmmBurnRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmBurnRequest()..mergeFromBuffer(data, registry);
  factory AmmBurnRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmBurnRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmBurnRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmBurnRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..aInt64(3, _omitFieldNames ? '' : 'lpTokenAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmBurnRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmBurnRequest copyWith(void Function(AmmBurnRequest) updates) =>
      super.copyWith((message) => updates(message as AmmBurnRequest)) as AmmBurnRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmBurnRequest() / AmmBurnRequest.new instead')
  static AmmBurnRequest create() => AmmBurnRequest._();
  static $pb.GeneratedMessage $_createMessage() => AmmBurnRequest._();
  @$core.override
  AmmBurnRequest createEmptyInstance() => AmmBurnRequest._();
  @$core.pragma('dart2js:noInline')
  static AmmBurnRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmBurnRequest>(AmmBurnRequest.$_createMessage);
  static AmmBurnRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lpTokenAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set lpTokenAmount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLpTokenAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearLpTokenAmount() => $_clearField(3);
}

class AmmBurnResponse extends $pb.GeneratedMessage {
  factory AmmBurnResponse({
    $core.String? txid,
  }) {
    final result = AmmBurnResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  AmmBurnResponse._();

  factory AmmBurnResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmBurnResponse()..mergeFromBuffer(data, registry);
  factory AmmBurnResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmBurnResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmBurnResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmBurnResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmBurnResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmBurnResponse copyWith(void Function(AmmBurnResponse) updates) =>
      super.copyWith((message) => updates(message as AmmBurnResponse)) as AmmBurnResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmBurnResponse() / AmmBurnResponse.new instead')
  static AmmBurnResponse create() => AmmBurnResponse._();
  static $pb.GeneratedMessage $_createMessage() => AmmBurnResponse._();
  @$core.override
  AmmBurnResponse createEmptyInstance() => AmmBurnResponse._();
  @$core.pragma('dart2js:noInline')
  static AmmBurnResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmBurnResponse>(AmmBurnResponse.$_createMessage);
  static AmmBurnResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class AmmMintRequest extends $pb.GeneratedMessage {
  factory AmmMintRequest({
    $core.String? asset0,
    $core.String? asset1,
    $fixnum.Int64? amount0,
    $fixnum.Int64? amount1,
  }) {
    final result = AmmMintRequest._();
    if (asset0 != null) result.asset0 = asset0;
    if (asset1 != null) result.asset1 = asset1;
    if (amount0 != null) result.amount0 = amount0;
    if (amount1 != null) result.amount1 = amount1;
    return result;
  }

  AmmMintRequest._();

  factory AmmMintRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmMintRequest()..mergeFromBuffer(data, registry);
  factory AmmMintRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmMintRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmMintRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmMintRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..aInt64(3, _omitFieldNames ? '' : 'amount0')
    ..aInt64(4, _omitFieldNames ? '' : 'amount1')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmMintRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmMintRequest copyWith(void Function(AmmMintRequest) updates) =>
      super.copyWith((message) => updates(message as AmmMintRequest)) as AmmMintRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmMintRequest() / AmmMintRequest.new instead')
  static AmmMintRequest create() => AmmMintRequest._();
  static $pb.GeneratedMessage $_createMessage() => AmmMintRequest._();
  @$core.override
  AmmMintRequest createEmptyInstance() => AmmMintRequest._();
  @$core.pragma('dart2js:noInline')
  static AmmMintRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmMintRequest>(AmmMintRequest.$_createMessage);
  static AmmMintRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount0 => $_getI64(2);
  @$pb.TagNumber(3)
  set amount0($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount0() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount0() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount1 => $_getI64(3);
  @$pb.TagNumber(4)
  set amount1($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount1() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount1() => $_clearField(4);
}

class AmmMintResponse extends $pb.GeneratedMessage {
  factory AmmMintResponse({
    $core.String? txid,
  }) {
    final result = AmmMintResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  AmmMintResponse._();

  factory AmmMintResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmMintResponse()..mergeFromBuffer(data, registry);
  factory AmmMintResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmMintResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmMintResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmMintResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmMintResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmMintResponse copyWith(void Function(AmmMintResponse) updates) =>
      super.copyWith((message) => updates(message as AmmMintResponse)) as AmmMintResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmMintResponse() / AmmMintResponse.new instead')
  static AmmMintResponse create() => AmmMintResponse._();
  static $pb.GeneratedMessage $_createMessage() => AmmMintResponse._();
  @$core.override
  AmmMintResponse createEmptyInstance() => AmmMintResponse._();
  @$core.pragma('dart2js:noInline')
  static AmmMintResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmMintResponse>(AmmMintResponse.$_createMessage);
  static AmmMintResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class AmmSwapRequest extends $pb.GeneratedMessage {
  factory AmmSwapRequest({
    $core.String? assetSpend,
    $core.String? assetReceive,
    $fixnum.Int64? amountSpend,
  }) {
    final result = AmmSwapRequest._();
    if (assetSpend != null) result.assetSpend = assetSpend;
    if (assetReceive != null) result.assetReceive = assetReceive;
    if (amountSpend != null) result.amountSpend = amountSpend;
    return result;
  }

  AmmSwapRequest._();

  factory AmmSwapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmSwapRequest()..mergeFromBuffer(data, registry);
  factory AmmSwapRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmSwapRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmSwapRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmSwapRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'assetSpend')
    ..aOS(2, _omitFieldNames ? '' : 'assetReceive')
    ..aInt64(3, _omitFieldNames ? '' : 'amountSpend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmSwapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmSwapRequest copyWith(void Function(AmmSwapRequest) updates) =>
      super.copyWith((message) => updates(message as AmmSwapRequest)) as AmmSwapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmSwapRequest() / AmmSwapRequest.new instead')
  static AmmSwapRequest create() => AmmSwapRequest._();
  static $pb.GeneratedMessage $_createMessage() => AmmSwapRequest._();
  @$core.override
  AmmSwapRequest createEmptyInstance() => AmmSwapRequest._();
  @$core.pragma('dart2js:noInline')
  static AmmSwapRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmSwapRequest>(AmmSwapRequest.$_createMessage);
  static AmmSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetSpend => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetSpend($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAssetSpend() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetSpend() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get assetReceive => $_getSZ(1);
  @$pb.TagNumber(2)
  set assetReceive($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAssetReceive() => $_has(1);
  @$pb.TagNumber(2)
  void clearAssetReceive() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSpend => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSpend($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountSpend() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSpend() => $_clearField(3);
}

class AmmSwapResponse extends $pb.GeneratedMessage {
  factory AmmSwapResponse({
    $fixnum.Int64? amountReceive,
  }) {
    final result = AmmSwapResponse._();
    if (amountReceive != null) result.amountReceive = amountReceive;
    return result;
  }

  AmmSwapResponse._();

  factory AmmSwapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmSwapResponse()..mergeFromBuffer(data, registry);
  factory AmmSwapResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AmmSwapResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AmmSwapResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: AmmSwapResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'amountReceive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmSwapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AmmSwapResponse copyWith(void Function(AmmSwapResponse) updates) =>
      super.copyWith((message) => updates(message as AmmSwapResponse)) as AmmSwapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AmmSwapResponse() / AmmSwapResponse.new instead')
  static AmmSwapResponse create() => AmmSwapResponse._();
  static $pb.GeneratedMessage $_createMessage() => AmmSwapResponse._();
  @$core.override
  AmmSwapResponse createEmptyInstance() => AmmSwapResponse._();
  @$core.pragma('dart2js:noInline')
  static AmmSwapResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AmmSwapResponse>(AmmSwapResponse.$_createMessage);
  static AmmSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountReceive => $_getI64(0);
  @$pb.TagNumber(1)
  set amountReceive($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmountReceive() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountReceive() => $_clearField(1);
}

class GetAmmPoolStateRequest extends $pb.GeneratedMessage {
  factory GetAmmPoolStateRequest({
    $core.String? asset0,
    $core.String? asset1,
  }) {
    final result = GetAmmPoolStateRequest._();
    if (asset0 != null) result.asset0 = asset0;
    if (asset1 != null) result.asset1 = asset1;
    return result;
  }

  GetAmmPoolStateRequest._();

  factory GetAmmPoolStateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPoolStateRequest()..mergeFromBuffer(data, registry);
  factory GetAmmPoolStateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPoolStateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPoolStateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetAmmPoolStateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'asset0')
    ..aOS(2, _omitFieldNames ? '' : 'asset1')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPoolStateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPoolStateRequest copyWith(void Function(GetAmmPoolStateRequest) updates) =>
      super.copyWith((message) => updates(message as GetAmmPoolStateRequest)) as GetAmmPoolStateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAmmPoolStateRequest() / GetAmmPoolStateRequest.new instead')
  static GetAmmPoolStateRequest create() => GetAmmPoolStateRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAmmPoolStateRequest._();
  @$core.override
  GetAmmPoolStateRequest createEmptyInstance() => GetAmmPoolStateRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAmmPoolStateRequest>(GetAmmPoolStateRequest.$_createMessage);
  static GetAmmPoolStateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asset0 => $_getSZ(0);
  @$pb.TagNumber(1)
  set asset0($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAsset0() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsset0() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset1($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAsset1() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset1() => $_clearField(2);
}

class GetAmmPoolStateResponse extends $pb.GeneratedMessage {
  factory GetAmmPoolStateResponse({
    $core.String? poolStateJson,
  }) {
    final result = GetAmmPoolStateResponse._();
    if (poolStateJson != null) result.poolStateJson = poolStateJson;
    return result;
  }

  GetAmmPoolStateResponse._();

  factory GetAmmPoolStateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPoolStateResponse()..mergeFromBuffer(data, registry);
  factory GetAmmPoolStateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPoolStateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPoolStateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetAmmPoolStateResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'poolStateJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPoolStateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPoolStateResponse copyWith(void Function(GetAmmPoolStateResponse) updates) =>
      super.copyWith((message) => updates(message as GetAmmPoolStateResponse)) as GetAmmPoolStateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAmmPoolStateResponse() / GetAmmPoolStateResponse.new instead')
  static GetAmmPoolStateResponse create() => GetAmmPoolStateResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAmmPoolStateResponse._();
  @$core.override
  GetAmmPoolStateResponse createEmptyInstance() => GetAmmPoolStateResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAmmPoolStateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAmmPoolStateResponse>(GetAmmPoolStateResponse.$_createMessage);
  static GetAmmPoolStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get poolStateJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set poolStateJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPoolStateJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPoolStateJson() => $_clearField(1);
}

class GetAmmPriceRequest extends $pb.GeneratedMessage {
  factory GetAmmPriceRequest({
    $core.String? base,
    $core.String? quote,
  }) {
    final result = GetAmmPriceRequest._();
    if (base != null) result.base = base;
    if (quote != null) result.quote = quote;
    return result;
  }

  GetAmmPriceRequest._();

  factory GetAmmPriceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPriceRequest()..mergeFromBuffer(data, registry);
  factory GetAmmPriceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPriceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPriceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetAmmPriceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'base')
    ..aOS(2, _omitFieldNames ? '' : 'quote')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPriceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPriceRequest copyWith(void Function(GetAmmPriceRequest) updates) =>
      super.copyWith((message) => updates(message as GetAmmPriceRequest)) as GetAmmPriceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAmmPriceRequest() / GetAmmPriceRequest.new instead')
  static GetAmmPriceRequest create() => GetAmmPriceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAmmPriceRequest._();
  @$core.override
  GetAmmPriceRequest createEmptyInstance() => GetAmmPriceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAmmPriceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPriceRequest>(GetAmmPriceRequest.$_createMessage);
  static GetAmmPriceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get base => $_getSZ(0);
  @$pb.TagNumber(1)
  set base($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quote => $_getSZ(1);
  @$pb.TagNumber(2)
  set quote($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuote() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuote() => $_clearField(2);
}

class GetAmmPriceResponse extends $pb.GeneratedMessage {
  factory GetAmmPriceResponse({
    $core.String? priceJson,
  }) {
    final result = GetAmmPriceResponse._();
    if (priceJson != null) result.priceJson = priceJson;
    return result;
  }

  GetAmmPriceResponse._();

  factory GetAmmPriceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPriceResponse()..mergeFromBuffer(data, registry);
  factory GetAmmPriceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAmmPriceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAmmPriceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: GetAmmPriceResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'priceJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPriceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAmmPriceResponse copyWith(void Function(GetAmmPriceResponse) updates) =>
      super.copyWith((message) => updates(message as GetAmmPriceResponse)) as GetAmmPriceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAmmPriceResponse() / GetAmmPriceResponse.new instead')
  static GetAmmPriceResponse create() => GetAmmPriceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAmmPriceResponse._();
  @$core.override
  GetAmmPriceResponse createEmptyInstance() => GetAmmPriceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAmmPriceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAmmPriceResponse>(GetAmmPriceResponse.$_createMessage);
  static GetAmmPriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priceJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set priceJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceJson() => $_clearField(1);
}

class DutchAuctionBidRequest extends $pb.GeneratedMessage {
  factory DutchAuctionBidRequest({
    $core.String? dutchAuctionId,
    $fixnum.Int64? bidSize,
  }) {
    final result = DutchAuctionBidRequest._();
    if (dutchAuctionId != null) result.dutchAuctionId = dutchAuctionId;
    if (bidSize != null) result.bidSize = bidSize;
    return result;
  }

  DutchAuctionBidRequest._();

  factory DutchAuctionBidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionBidRequest()..mergeFromBuffer(data, registry);
  factory DutchAuctionBidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionBidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionBidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionBidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dutchAuctionId')
    ..aInt64(2, _omitFieldNames ? '' : 'bidSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionBidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionBidRequest copyWith(void Function(DutchAuctionBidRequest) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionBidRequest)) as DutchAuctionBidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionBidRequest() / DutchAuctionBidRequest.new instead')
  static DutchAuctionBidRequest create() => DutchAuctionBidRequest._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionBidRequest._();
  @$core.override
  DutchAuctionBidRequest createEmptyInstance() => DutchAuctionBidRequest._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionBidRequest>(DutchAuctionBidRequest.$_createMessage);
  static DutchAuctionBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dutchAuctionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dutchAuctionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDutchAuctionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDutchAuctionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get bidSize => $_getI64(1);
  @$pb.TagNumber(2)
  set bidSize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBidSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBidSize() => $_clearField(2);
}

class DutchAuctionBidResponse extends $pb.GeneratedMessage {
  factory DutchAuctionBidResponse({
    $fixnum.Int64? baseAmount,
  }) {
    final result = DutchAuctionBidResponse._();
    if (baseAmount != null) result.baseAmount = baseAmount;
    return result;
  }

  DutchAuctionBidResponse._();

  factory DutchAuctionBidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionBidResponse()..mergeFromBuffer(data, registry);
  factory DutchAuctionBidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionBidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionBidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionBidResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'baseAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionBidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionBidResponse copyWith(void Function(DutchAuctionBidResponse) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionBidResponse)) as DutchAuctionBidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionBidResponse() / DutchAuctionBidResponse.new instead')
  static DutchAuctionBidResponse create() => DutchAuctionBidResponse._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionBidResponse._();
  @$core.override
  DutchAuctionBidResponse createEmptyInstance() => DutchAuctionBidResponse._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionBidResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionBidResponse>(DutchAuctionBidResponse.$_createMessage);
  static DutchAuctionBidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get baseAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set baseAmount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBaseAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAmount() => $_clearField(1);
}

class DutchAuctionCollectRequest extends $pb.GeneratedMessage {
  factory DutchAuctionCollectRequest({
    $core.String? dutchAuctionId,
  }) {
    final result = DutchAuctionCollectRequest._();
    if (dutchAuctionId != null) result.dutchAuctionId = dutchAuctionId;
    return result;
  }

  DutchAuctionCollectRequest._();

  factory DutchAuctionCollectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCollectRequest()..mergeFromBuffer(data, registry);
  factory DutchAuctionCollectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCollectRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCollectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionCollectRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dutchAuctionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCollectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCollectRequest copyWith(void Function(DutchAuctionCollectRequest) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionCollectRequest)) as DutchAuctionCollectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionCollectRequest() / DutchAuctionCollectRequest.new instead')
  static DutchAuctionCollectRequest create() => DutchAuctionCollectRequest._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionCollectRequest._();
  @$core.override
  DutchAuctionCollectRequest createEmptyInstance() => DutchAuctionCollectRequest._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionCollectRequest>(DutchAuctionCollectRequest.$_createMessage);
  static DutchAuctionCollectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dutchAuctionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dutchAuctionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDutchAuctionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDutchAuctionId() => $_clearField(1);
}

class DutchAuctionCollectResponse extends $pb.GeneratedMessage {
  factory DutchAuctionCollectResponse({
    $fixnum.Int64? baseAmount,
    $fixnum.Int64? quoteAmount,
  }) {
    final result = DutchAuctionCollectResponse._();
    if (baseAmount != null) result.baseAmount = baseAmount;
    if (quoteAmount != null) result.quoteAmount = quoteAmount;
    return result;
  }

  DutchAuctionCollectResponse._();

  factory DutchAuctionCollectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCollectResponse()..mergeFromBuffer(data, registry);
  factory DutchAuctionCollectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCollectResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCollectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionCollectResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'baseAmount')
    ..aInt64(2, _omitFieldNames ? '' : 'quoteAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCollectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCollectResponse copyWith(void Function(DutchAuctionCollectResponse) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionCollectResponse)) as DutchAuctionCollectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionCollectResponse() / DutchAuctionCollectResponse.new instead')
  static DutchAuctionCollectResponse create() => DutchAuctionCollectResponse._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionCollectResponse._();
  @$core.override
  DutchAuctionCollectResponse createEmptyInstance() => DutchAuctionCollectResponse._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCollectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionCollectResponse>(DutchAuctionCollectResponse.$_createMessage);
  static DutchAuctionCollectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get baseAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set baseAmount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBaseAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAmount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quoteAmount => $_getI64(1);
  @$pb.TagNumber(2)
  set quoteAmount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuoteAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuoteAmount() => $_clearField(2);
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
    final result = DutchAuctionCreateRequest._();
    if (startBlock != null) result.startBlock = startBlock;
    if (duration != null) result.duration = duration;
    if (baseAsset != null) result.baseAsset = baseAsset;
    if (baseAmount != null) result.baseAmount = baseAmount;
    if (quoteAsset != null) result.quoteAsset = quoteAsset;
    if (initialPrice != null) result.initialPrice = initialPrice;
    if (finalPrice != null) result.finalPrice = finalPrice;
    return result;
  }

  DutchAuctionCreateRequest._();

  factory DutchAuctionCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCreateRequest()..mergeFromBuffer(data, registry);
  factory DutchAuctionCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionCreateRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'startBlock')
    ..aInt64(2, _omitFieldNames ? '' : 'duration')
    ..aOS(3, _omitFieldNames ? '' : 'baseAsset')
    ..aInt64(4, _omitFieldNames ? '' : 'baseAmount')
    ..aOS(5, _omitFieldNames ? '' : 'quoteAsset')
    ..aInt64(6, _omitFieldNames ? '' : 'initialPrice')
    ..aInt64(7, _omitFieldNames ? '' : 'finalPrice')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCreateRequest copyWith(void Function(DutchAuctionCreateRequest) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionCreateRequest)) as DutchAuctionCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionCreateRequest() / DutchAuctionCreateRequest.new instead')
  static DutchAuctionCreateRequest create() => DutchAuctionCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionCreateRequest._();
  @$core.override
  DutchAuctionCreateRequest createEmptyInstance() => DutchAuctionCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionCreateRequest>(DutchAuctionCreateRequest.$_createMessage);
  static DutchAuctionCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get startBlock => $_getI64(0);
  @$pb.TagNumber(1)
  set startBlock($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartBlock() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get duration => $_getI64(1);
  @$pb.TagNumber(2)
  set duration($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get baseAsset => $_getSZ(2);
  @$pb.TagNumber(3)
  set baseAsset($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBaseAsset() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaseAsset() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get baseAmount => $_getI64(3);
  @$pb.TagNumber(4)
  set baseAmount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBaseAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearBaseAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get quoteAsset => $_getSZ(4);
  @$pb.TagNumber(5)
  set quoteAsset($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuoteAsset() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuoteAsset() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get initialPrice => $_getI64(5);
  @$pb.TagNumber(6)
  set initialPrice($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInitialPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearInitialPrice() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get finalPrice => $_getI64(6);
  @$pb.TagNumber(7)
  set finalPrice($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFinalPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearFinalPrice() => $_clearField(7);
}

class DutchAuctionCreateResponse extends $pb.GeneratedMessage {
  factory DutchAuctionCreateResponse({
    $core.String? txid,
  }) {
    final result = DutchAuctionCreateResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  DutchAuctionCreateResponse._();

  factory DutchAuctionCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCreateResponse()..mergeFromBuffer(data, registry);
  factory DutchAuctionCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionCreateResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionCreateResponse copyWith(void Function(DutchAuctionCreateResponse) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionCreateResponse)) as DutchAuctionCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionCreateResponse() / DutchAuctionCreateResponse.new instead')
  static DutchAuctionCreateResponse create() => DutchAuctionCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionCreateResponse._();
  @$core.override
  DutchAuctionCreateResponse createEmptyInstance() => DutchAuctionCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionCreateResponse>(DutchAuctionCreateResponse.$_createMessage);
  static DutchAuctionCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class DutchAuctionsRequest extends $pb.GeneratedMessage {
  factory DutchAuctionsRequest() => DutchAuctionsRequest._();

  DutchAuctionsRequest._();

  factory DutchAuctionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionsRequest()..mergeFromBuffer(data, registry);
  factory DutchAuctionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionsRequest copyWith(void Function(DutchAuctionsRequest) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionsRequest)) as DutchAuctionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionsRequest() / DutchAuctionsRequest.new instead')
  static DutchAuctionsRequest create() => DutchAuctionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionsRequest._();
  @$core.override
  DutchAuctionsRequest createEmptyInstance() => DutchAuctionsRequest._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionsRequest>(DutchAuctionsRequest.$_createMessage);
  static DutchAuctionsRequest? _defaultInstance;
}

class DutchAuctionsResponse extends $pb.GeneratedMessage {
  factory DutchAuctionsResponse({
    $core.String? auctionsJson,
  }) {
    final result = DutchAuctionsResponse._();
    if (auctionsJson != null) result.auctionsJson = auctionsJson;
    return result;
  }

  DutchAuctionsResponse._();

  factory DutchAuctionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionsResponse()..mergeFromBuffer(data, registry);
  factory DutchAuctionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DutchAuctionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DutchAuctionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitassets.v1'),
      createEmptyInstance: DutchAuctionsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'auctionsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DutchAuctionsResponse copyWith(void Function(DutchAuctionsResponse) updates) =>
      super.copyWith((message) => updates(message as DutchAuctionsResponse)) as DutchAuctionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DutchAuctionsResponse() / DutchAuctionsResponse.new instead')
  static DutchAuctionsResponse create() => DutchAuctionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => DutchAuctionsResponse._();
  @$core.override
  DutchAuctionsResponse createEmptyInstance() => DutchAuctionsResponse._();
  @$core.pragma('dart2js:noInline')
  static DutchAuctionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DutchAuctionsResponse>(DutchAuctionsResponse.$_createMessage);
  static DutchAuctionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get auctionsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set auctionsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuctionsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuctionsJson() => $_clearField(1);
}

class BitAssetsServiceApi {
  final $pb.RpcClient _client;

  BitAssetsServiceApi(this._client);

  /// Get wallet balance (total and available).
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'BitAssetsService', 'GetBalance', request, GetBalanceResponse());

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'BitAssetsService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Stop the bitassets node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'BitAssetsService', 'Stop', request, StopResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'BitAssetsService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Withdraw to mainchain.
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
      _client.invoke<WithdrawResponse>(ctx, 'BitAssetsService', 'Withdraw', request, WithdrawResponse());

  /// Transfer within sidechain.
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
      _client.invoke<TransferResponse>(ctx, 'BitAssetsService', 'Transfer', request, TransferResponse());

  /// Get total sidechain wealth in sats.
  $async.Future<GetSidechainWealthResponse> getSidechainWealth(
          $pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
      _client.invoke<GetSidechainWealthResponse>(
          ctx, 'BitAssetsService', 'GetSidechainWealth', request, GetSidechainWealthResponse());

  /// Create a deposit transaction.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
      _client.invoke<CreateDepositResponse>(ctx, 'BitAssetsService', 'CreateDeposit', request, CreateDepositResponse());

  /// Get pending withdrawal bundle.
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
          $pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
      _client.invoke<GetPendingWithdrawalBundleResponse>(
          ctx, 'BitAssetsService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse());

  /// Connect to a peer.
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
      _client.invoke<ConnectPeerResponse>(ctx, 'BitAssetsService', 'ConnectPeer', request, ConnectPeerResponse());

  /// Forget a peer.
  $async.Future<ForgetPeerResponse> forgetPeer($pb.ClientContext? ctx, ForgetPeerRequest request) =>
      _client.invoke<ForgetPeerResponse>(ctx, 'BitAssetsService', 'ForgetPeer', request, ForgetPeerResponse());

  /// List connected peers.
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
      _client.invoke<ListPeersResponse>(ctx, 'BitAssetsService', 'ListPeers', request, ListPeersResponse());

  /// Mine a block.
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
      _client.invoke<MineResponse>(ctx, 'BitAssetsService', 'Mine', request, MineResponse());

  /// Get block by hash.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'BitAssetsService', 'GetBlock', request, GetBlockResponse());

  /// Get best mainchain block hash.
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
          $pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
      _client.invoke<GetBestMainchainBlockHashResponse>(
          ctx, 'BitAssetsService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse());

  /// Get best sidechain block hash.
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
          $pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
      _client.invoke<GetBestSidechainBlockHashResponse>(
          ctx, 'BitAssetsService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse());

  /// Get BMM inclusions for a block.
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
      _client.invoke<GetBmmInclusionsResponse>(
          ctx, 'BitAssetsService', 'GetBmmInclusions', request, GetBmmInclusionsResponse());

  /// Get wallet UTXOs.
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) => _client
      .invoke<GetWalletUtxosResponse>(ctx, 'BitAssetsService', 'GetWalletUtxos', request, GetWalletUtxosResponse());

  /// List all UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'BitAssetsService', 'ListUtxos', request, ListUtxosResponse());

  /// Remove transaction from mempool.
  $async.Future<RemoveFromMempoolResponse> removeFromMempool(
          $pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
      _client.invoke<RemoveFromMempoolResponse>(
          ctx, 'BitAssetsService', 'RemoveFromMempool', request, RemoveFromMempoolResponse());

  /// Get latest failed withdrawal bundle height.
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
          $pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
      _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'BitAssetsService',
          'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse());

  /// Generate a new mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'BitAssetsService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// Set seed from mnemonic.
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic(
          $pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
      _client.invoke<SetSeedFromMnemonicResponse>(
          ctx, 'BitAssetsService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse());

  /// Raw JSON-RPC passthrough for debug console.
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
      _client.invoke<CallRawResponse>(ctx, 'BitAssetsService', 'CallRaw', request, CallRawResponse());

  /// Get BitAsset data by asset ID.
  $async.Future<GetBitAssetDataResponse> getBitAssetData($pb.ClientContext? ctx, GetBitAssetDataRequest request) =>
      _client.invoke<GetBitAssetDataResponse>(
          ctx, 'BitAssetsService', 'GetBitAssetData', request, GetBitAssetDataResponse());

  /// List all BitAssets.
  $async.Future<ListBitAssetsResponse> listBitAssets($pb.ClientContext? ctx, ListBitAssetsRequest request) =>
      _client.invoke<ListBitAssetsResponse>(ctx, 'BitAssetsService', 'ListBitAssets', request, ListBitAssetsResponse());

  /// Register a BitAsset.
  $async.Future<RegisterBitAssetResponse> registerBitAsset($pb.ClientContext? ctx, RegisterBitAssetRequest request) =>
      _client.invoke<RegisterBitAssetResponse>(
          ctx, 'BitAssetsService', 'RegisterBitAsset', request, RegisterBitAssetResponse());

  /// Reserve a BitAsset.
  $async.Future<ReserveBitAssetResponse> reserveBitAsset($pb.ClientContext? ctx, ReserveBitAssetRequest request) =>
      _client.invoke<ReserveBitAssetResponse>(
          ctx, 'BitAssetsService', 'ReserveBitAsset', request, ReserveBitAssetResponse());

  /// Transfer a BitAsset token.
  $async.Future<TransferBitAssetResponse> transferBitAsset($pb.ClientContext? ctx, TransferBitAssetRequest request) =>
      _client.invoke<TransferBitAssetResponse>(
          ctx, 'BitAssetsService', 'TransferBitAsset', request, TransferBitAssetResponse());

  /// Get a new encryption key.
  $async.Future<GetNewEncryptionKeyResponse> getNewEncryptionKey(
          $pb.ClientContext? ctx, GetNewEncryptionKeyRequest request) =>
      _client.invoke<GetNewEncryptionKeyResponse>(
          ctx, 'BitAssetsService', 'GetNewEncryptionKey', request, GetNewEncryptionKeyResponse());

  /// Get a new verifying key.
  $async.Future<GetNewVerifyingKeyResponse> getNewVerifyingKey(
          $pb.ClientContext? ctx, GetNewVerifyingKeyRequest request) =>
      _client.invoke<GetNewVerifyingKeyResponse>(
          ctx, 'BitAssetsService', 'GetNewVerifyingKey', request, GetNewVerifyingKeyResponse());

  /// Decrypt a message.
  $async.Future<DecryptMsgResponse> decryptMsg($pb.ClientContext? ctx, DecryptMsgRequest request) =>
      _client.invoke<DecryptMsgResponse>(ctx, 'BitAssetsService', 'DecryptMsg', request, DecryptMsgResponse());

  /// Encrypt a message.
  $async.Future<EncryptMsgResponse> encryptMsg($pb.ClientContext? ctx, EncryptMsgRequest request) =>
      _client.invoke<EncryptMsgResponse>(ctx, 'BitAssetsService', 'EncryptMsg', request, EncryptMsgResponse());

  /// Sign an arbitrary message with the specified verifying key.
  $async.Future<SignArbitraryMsgResponse> signArbitraryMsg($pb.ClientContext? ctx, SignArbitraryMsgRequest request) =>
      _client.invoke<SignArbitraryMsgResponse>(
          ctx, 'BitAssetsService', 'SignArbitraryMsg', request, SignArbitraryMsgResponse());

  /// Sign an arbitrary message as a specific address.
  $async.Future<SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
          $pb.ClientContext? ctx, SignArbitraryMsgAsAddrRequest request) =>
      _client.invoke<SignArbitraryMsgAsAddrResponse>(
          ctx, 'BitAssetsService', 'SignArbitraryMsgAsAddr', request, SignArbitraryMsgAsAddrResponse());

  /// Verify a signature.
  $async.Future<VerifySignatureResponse> verifySignature($pb.ClientContext? ctx, VerifySignatureRequest request) =>
      _client.invoke<VerifySignatureResponse>(
          ctx, 'BitAssetsService', 'VerifySignature', request, VerifySignatureResponse());

  /// Get wallet addresses.
  $async.Future<GetWalletAddressesResponse> getWalletAddresses(
          $pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
      _client.invoke<GetWalletAddressesResponse>(
          ctx, 'BitAssetsService', 'GetWalletAddresses', request, GetWalletAddressesResponse());

  /// List unconfirmed owned UTXOs.
  $async.Future<MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
          $pb.ClientContext? ctx, MyUnconfirmedUtxosRequest request) =>
      _client.invoke<MyUnconfirmedUtxosResponse>(
          ctx, 'BitAssetsService', 'MyUnconfirmedUtxos', request, MyUnconfirmedUtxosResponse());

  /// Get OpenAPI schema.
  $async.Future<OpenapiSchemaResponse> openapiSchema($pb.ClientContext? ctx, OpenapiSchemaRequest request) =>
      _client.invoke<OpenapiSchemaResponse>(ctx, 'BitAssetsService', 'OpenapiSchema', request, OpenapiSchemaResponse());

  /// Burn an AMM position.
  $async.Future<AmmBurnResponse> ammBurn($pb.ClientContext? ctx, AmmBurnRequest request) =>
      _client.invoke<AmmBurnResponse>(ctx, 'BitAssetsService', 'AmmBurn', request, AmmBurnResponse());

  /// Mint an AMM position.
  $async.Future<AmmMintResponse> ammMint($pb.ClientContext? ctx, AmmMintRequest request) =>
      _client.invoke<AmmMintResponse>(ctx, 'BitAssetsService', 'AmmMint', request, AmmMintResponse());

  /// AMM swap.
  $async.Future<AmmSwapResponse> ammSwap($pb.ClientContext? ctx, AmmSwapRequest request) =>
      _client.invoke<AmmSwapResponse>(ctx, 'BitAssetsService', 'AmmSwap', request, AmmSwapResponse());

  /// Get the state of the specified AMM pool.
  $async.Future<GetAmmPoolStateResponse> getAmmPoolState($pb.ClientContext? ctx, GetAmmPoolStateRequest request) =>
      _client.invoke<GetAmmPoolStateResponse>(
          ctx, 'BitAssetsService', 'GetAmmPoolState', request, GetAmmPoolStateResponse());

  /// Get the current price for the specified pair.
  $async.Future<GetAmmPriceResponse> getAmmPrice($pb.ClientContext? ctx, GetAmmPriceRequest request) =>
      _client.invoke<GetAmmPriceResponse>(ctx, 'BitAssetsService', 'GetAmmPrice', request, GetAmmPriceResponse());

  /// Bid on a dutch auction.
  $async.Future<DutchAuctionBidResponse> dutchAuctionBid($pb.ClientContext? ctx, DutchAuctionBidRequest request) =>
      _client.invoke<DutchAuctionBidResponse>(
          ctx, 'BitAssetsService', 'DutchAuctionBid', request, DutchAuctionBidResponse());

  /// Collect from a dutch auction.
  $async.Future<DutchAuctionCollectResponse> dutchAuctionCollect(
          $pb.ClientContext? ctx, DutchAuctionCollectRequest request) =>
      _client.invoke<DutchAuctionCollectResponse>(
          ctx, 'BitAssetsService', 'DutchAuctionCollect', request, DutchAuctionCollectResponse());

  /// Create a dutch auction.
  $async.Future<DutchAuctionCreateResponse> dutchAuctionCreate(
          $pb.ClientContext? ctx, DutchAuctionCreateRequest request) =>
      _client.invoke<DutchAuctionCreateResponse>(
          ctx, 'BitAssetsService', 'DutchAuctionCreate', request, DutchAuctionCreateResponse());

  /// List all dutch auctions.
  $async.Future<DutchAuctionsResponse> dutchAuctions($pb.ClientContext? ctx, DutchAuctionsRequest request) =>
      _client.invoke<DutchAuctionsResponse>(ctx, 'BitAssetsService', 'DutchAuctions', request, DutchAuctionsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
