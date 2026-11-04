// This is a generated file - do not edit.
//
// Generated from bitnames/v1/bitnames.proto.

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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

class GetBitNameDataRequest extends $pb.GeneratedMessage {
  factory GetBitNameDataRequest({
    $core.String? name,
  }) {
    final result = GetBitNameDataRequest._();
    if (name != null) result.name = name;
    return result;
  }

  GetBitNameDataRequest._();

  factory GetBitNameDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameDataRequest()..mergeFromBuffer(data, registry);
  factory GetBitNameDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameDataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitNameDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetBitNameDataRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameDataRequest copyWith(void Function(GetBitNameDataRequest) updates) =>
      super.copyWith((message) => updates(message as GetBitNameDataRequest)) as GetBitNameDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitNameDataRequest() / GetBitNameDataRequest.new instead')
  static GetBitNameDataRequest create() => GetBitNameDataRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBitNameDataRequest._();
  @$core.override
  GetBitNameDataRequest createEmptyInstance() => GetBitNameDataRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBitNameDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitNameDataRequest>(GetBitNameDataRequest.$_createMessage);
  static GetBitNameDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class GetBitNameDataResponse extends $pb.GeneratedMessage {
  factory GetBitNameDataResponse({
    $core.String? dataJson,
  }) {
    final result = GetBitNameDataResponse._();
    if (dataJson != null) result.dataJson = dataJson;
    return result;
  }

  GetBitNameDataResponse._();

  factory GetBitNameDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameDataResponse()..mergeFromBuffer(data, registry);
  factory GetBitNameDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameDataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitNameDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetBitNameDataResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameDataResponse copyWith(void Function(GetBitNameDataResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitNameDataResponse)) as GetBitNameDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitNameDataResponse() / GetBitNameDataResponse.new instead')
  static GetBitNameDataResponse create() => GetBitNameDataResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBitNameDataResponse._();
  @$core.override
  GetBitNameDataResponse createEmptyInstance() => GetBitNameDataResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBitNameDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitNameDataResponse>(GetBitNameDataResponse.$_createMessage);
  static GetBitNameDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataJson() => $_clearField(1);
}

class ListBitNamesRequest extends $pb.GeneratedMessage {
  factory ListBitNamesRequest() => ListBitNamesRequest._();

  ListBitNamesRequest._();

  factory ListBitNamesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitNamesRequest()..mergeFromBuffer(data, registry);
  factory ListBitNamesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitNamesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitNamesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ListBitNamesRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitNamesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitNamesRequest copyWith(void Function(ListBitNamesRequest) updates) =>
      super.copyWith((message) => updates(message as ListBitNamesRequest)) as ListBitNamesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBitNamesRequest() / ListBitNamesRequest.new instead')
  static ListBitNamesRequest create() => ListBitNamesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBitNamesRequest._();
  @$core.override
  ListBitNamesRequest createEmptyInstance() => ListBitNamesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBitNamesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBitNamesRequest>(ListBitNamesRequest.$_createMessage);
  static ListBitNamesRequest? _defaultInstance;
}

class ListBitNamesResponse extends $pb.GeneratedMessage {
  factory ListBitNamesResponse({
    $core.String? bitnamesJson,
  }) {
    final result = ListBitNamesResponse._();
    if (bitnamesJson != null) result.bitnamesJson = bitnamesJson;
    return result;
  }

  ListBitNamesResponse._();

  factory ListBitNamesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitNamesResponse()..mergeFromBuffer(data, registry);
  factory ListBitNamesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBitNamesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBitNamesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ListBitNamesResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bitnamesJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitNamesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBitNamesResponse copyWith(void Function(ListBitNamesResponse) updates) =>
      super.copyWith((message) => updates(message as ListBitNamesResponse)) as ListBitNamesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBitNamesResponse() / ListBitNamesResponse.new instead')
  static ListBitNamesResponse create() => ListBitNamesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBitNamesResponse._();
  @$core.override
  ListBitNamesResponse createEmptyInstance() => ListBitNamesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBitNamesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBitNamesResponse>(ListBitNamesResponse.$_createMessage);
  static ListBitNamesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bitnamesJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set bitnamesJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBitnamesJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitnamesJson() => $_clearField(1);
}

class RegisterBitNameRequest extends $pb.GeneratedMessage {
  factory RegisterBitNameRequest({
    $core.String? plainName,
    $core.String? dataJson,
  }) {
    final result = RegisterBitNameRequest._();
    if (plainName != null) result.plainName = plainName;
    if (dataJson != null) result.dataJson = dataJson;
    return result;
  }

  RegisterBitNameRequest._();

  factory RegisterBitNameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitNameRequest()..mergeFromBuffer(data, registry);
  factory RegisterBitNameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitNameRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitNameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: RegisterBitNameRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'plainName')
    ..aOS(2, _omitFieldNames ? '' : 'dataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitNameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitNameRequest copyWith(void Function(RegisterBitNameRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterBitNameRequest)) as RegisterBitNameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterBitNameRequest() / RegisterBitNameRequest.new instead')
  static RegisterBitNameRequest create() => RegisterBitNameRequest._();
  static $pb.GeneratedMessage $_createMessage() => RegisterBitNameRequest._();
  @$core.override
  RegisterBitNameRequest createEmptyInstance() => RegisterBitNameRequest._();
  @$core.pragma('dart2js:noInline')
  static RegisterBitNameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterBitNameRequest>(RegisterBitNameRequest.$_createMessage);
  static RegisterBitNameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set plainName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlainName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dataJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataJson() => $_clearField(2);
}

class RegisterBitNameResponse extends $pb.GeneratedMessage {
  factory RegisterBitNameResponse({
    $core.String? txid,
  }) {
    final result = RegisterBitNameResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  RegisterBitNameResponse._();

  factory RegisterBitNameResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitNameResponse()..mergeFromBuffer(data, registry);
  factory RegisterBitNameResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterBitNameResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterBitNameResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: RegisterBitNameResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitNameResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterBitNameResponse copyWith(void Function(RegisterBitNameResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterBitNameResponse)) as RegisterBitNameResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterBitNameResponse() / RegisterBitNameResponse.new instead')
  static RegisterBitNameResponse create() => RegisterBitNameResponse._();
  static $pb.GeneratedMessage $_createMessage() => RegisterBitNameResponse._();
  @$core.override
  RegisterBitNameResponse createEmptyInstance() => RegisterBitNameResponse._();
  @$core.pragma('dart2js:noInline')
  static RegisterBitNameResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterBitNameResponse>(RegisterBitNameResponse.$_createMessage);
  static RegisterBitNameResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class ReserveBitNameRequest extends $pb.GeneratedMessage {
  factory ReserveBitNameRequest({
    $core.String? name,
  }) {
    final result = ReserveBitNameRequest._();
    if (name != null) result.name = name;
    return result;
  }

  ReserveBitNameRequest._();

  factory ReserveBitNameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitNameRequest()..mergeFromBuffer(data, registry);
  factory ReserveBitNameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitNameRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitNameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ReserveBitNameRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitNameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitNameRequest copyWith(void Function(ReserveBitNameRequest) updates) =>
      super.copyWith((message) => updates(message as ReserveBitNameRequest)) as ReserveBitNameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveBitNameRequest() / ReserveBitNameRequest.new instead')
  static ReserveBitNameRequest create() => ReserveBitNameRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReserveBitNameRequest._();
  @$core.override
  ReserveBitNameRequest createEmptyInstance() => ReserveBitNameRequest._();
  @$core.pragma('dart2js:noInline')
  static ReserveBitNameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReserveBitNameRequest>(ReserveBitNameRequest.$_createMessage);
  static ReserveBitNameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class ReserveBitNameResponse extends $pb.GeneratedMessage {
  factory ReserveBitNameResponse({
    $core.String? txid,
  }) {
    final result = ReserveBitNameResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  ReserveBitNameResponse._();

  factory ReserveBitNameResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitNameResponse()..mergeFromBuffer(data, registry);
  factory ReserveBitNameResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveBitNameResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveBitNameResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ReserveBitNameResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitNameResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveBitNameResponse copyWith(void Function(ReserveBitNameResponse) updates) =>
      super.copyWith((message) => updates(message as ReserveBitNameResponse)) as ReserveBitNameResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveBitNameResponse() / ReserveBitNameResponse.new instead')
  static ReserveBitNameResponse create() => ReserveBitNameResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReserveBitNameResponse._();
  @$core.override
  ReserveBitNameResponse createEmptyInstance() => ReserveBitNameResponse._();
  @$core.pragma('dart2js:noInline')
  static ReserveBitNameResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReserveBitNameResponse>(ReserveBitNameResponse.$_createMessage);
  static ReserveBitNameResponse? _defaultInstance;

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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

class GetBitNameOwnerRequest extends $pb.GeneratedMessage {
  factory GetBitNameOwnerRequest({
    $core.String? bitname,
  }) {
    final result = GetBitNameOwnerRequest._();
    if (bitname != null) result.bitname = bitname;
    return result;
  }

  GetBitNameOwnerRequest._();

  factory GetBitNameOwnerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameOwnerRequest()..mergeFromBuffer(data, registry);
  factory GetBitNameOwnerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameOwnerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitNameOwnerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetBitNameOwnerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bitname')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameOwnerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameOwnerRequest copyWith(void Function(GetBitNameOwnerRequest) updates) =>
      super.copyWith((message) => updates(message as GetBitNameOwnerRequest)) as GetBitNameOwnerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitNameOwnerRequest() / GetBitNameOwnerRequest.new instead')
  static GetBitNameOwnerRequest create() => GetBitNameOwnerRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBitNameOwnerRequest._();
  @$core.override
  GetBitNameOwnerRequest createEmptyInstance() => GetBitNameOwnerRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBitNameOwnerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitNameOwnerRequest>(GetBitNameOwnerRequest.$_createMessage);
  static GetBitNameOwnerRequest? _defaultInstance;

  /// The BitName hash, as hexadecimal.
  @$pb.TagNumber(1)
  $core.String get bitname => $_getSZ(0);
  @$pb.TagNumber(1)
  set bitname($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBitname() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitname() => $_clearField(1);
}

class GetBitNameOwnerResponse extends $pb.GeneratedMessage {
  factory GetBitNameOwnerResponse({
    $core.String? address,
  }) {
    final result = GetBitNameOwnerResponse._();
    if (address != null) result.address = address;
    return result;
  }

  GetBitNameOwnerResponse._();

  factory GetBitNameOwnerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameOwnerResponse()..mergeFromBuffer(data, registry);
  factory GetBitNameOwnerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitNameOwnerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitNameOwnerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetBitNameOwnerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameOwnerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitNameOwnerResponse copyWith(void Function(GetBitNameOwnerResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitNameOwnerResponse)) as GetBitNameOwnerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitNameOwnerResponse() / GetBitNameOwnerResponse.new instead')
  static GetBitNameOwnerResponse create() => GetBitNameOwnerResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBitNameOwnerResponse._();
  @$core.override
  GetBitNameOwnerResponse createEmptyInstance() => GetBitNameOwnerResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBitNameOwnerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitNameOwnerResponse>(GetBitNameOwnerResponse.$_createMessage);
  static GetBitNameOwnerResponse? _defaultInstance;

  /// The address that holds the BitName today.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class GetPendingPaymailRequest extends $pb.GeneratedMessage {
  factory GetPendingPaymailRequest() => GetPendingPaymailRequest._();

  GetPendingPaymailRequest._();

  factory GetPendingPaymailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingPaymailRequest()..mergeFromBuffer(data, registry);
  factory GetPendingPaymailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingPaymailRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingPaymailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetPendingPaymailRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingPaymailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingPaymailRequest copyWith(void Function(GetPendingPaymailRequest) updates) =>
      super.copyWith((message) => updates(message as GetPendingPaymailRequest)) as GetPendingPaymailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingPaymailRequest() / GetPendingPaymailRequest.new instead')
  static GetPendingPaymailRequest create() => GetPendingPaymailRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingPaymailRequest._();
  @$core.override
  GetPendingPaymailRequest createEmptyInstance() => GetPendingPaymailRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPendingPaymailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPendingPaymailRequest>(GetPendingPaymailRequest.$_createMessage);
  static GetPendingPaymailRequest? _defaultInstance;
}

class GetPendingPaymailResponse extends $pb.GeneratedMessage {
  factory GetPendingPaymailResponse({
    $core.String? paymailJson,
    $core.Iterable<$core.String>? mempoolTxids,
  }) {
    final result = GetPendingPaymailResponse._();
    if (paymailJson != null) result.paymailJson = paymailJson;
    if (mempoolTxids != null) result.mempoolTxids.addAll(mempoolTxids);
    return result;
  }

  GetPendingPaymailResponse._();

  factory GetPendingPaymailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingPaymailResponse()..mergeFromBuffer(data, registry);
  factory GetPendingPaymailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingPaymailResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingPaymailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetPendingPaymailResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymailJson')
    ..pPS(2, _omitFieldNames ? '' : 'mempoolTxids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingPaymailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingPaymailResponse copyWith(void Function(GetPendingPaymailResponse) updates) =>
      super.copyWith((message) => updates(message as GetPendingPaymailResponse)) as GetPendingPaymailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingPaymailResponse() / GetPendingPaymailResponse.new instead')
  static GetPendingPaymailResponse create() => GetPendingPaymailResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingPaymailResponse._();
  @$core.override
  GetPendingPaymailResponse createEmptyInstance() => GetPendingPaymailResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPendingPaymailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPendingPaymailResponse>(GetPendingPaymailResponse.$_createMessage);
  static GetPendingPaymailResponse? _defaultInstance;

  /// The same JSON object GetPaymail returns, holding only the outputs that
  /// wait in the mempool.
  @$pb.TagNumber(1)
  $core.String get paymailJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymailJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymailJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymailJson() => $_clearField(1);

  /// Every transaction the mempool holds. A message a caller sent pays the
  /// reader, so no paymail feed reports it, and this says whether it waits.
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get mempoolTxids => $_getList(1);
}

class GetPaymailRequest extends $pb.GeneratedMessage {
  factory GetPaymailRequest() => GetPaymailRequest._();

  GetPaymailRequest._();

  factory GetPaymailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPaymailRequest()..mergeFromBuffer(data, registry);
  factory GetPaymailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPaymailRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPaymailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetPaymailRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPaymailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPaymailRequest copyWith(void Function(GetPaymailRequest) updates) =>
      super.copyWith((message) => updates(message as GetPaymailRequest)) as GetPaymailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPaymailRequest() / GetPaymailRequest.new instead')
  static GetPaymailRequest create() => GetPaymailRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPaymailRequest._();
  @$core.override
  GetPaymailRequest createEmptyInstance() => GetPaymailRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPaymailRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPaymailRequest>(GetPaymailRequest.$_createMessage);
  static GetPaymailRequest? _defaultInstance;
}

class GetPaymailResponse extends $pb.GeneratedMessage {
  factory GetPaymailResponse({
    $core.String? paymailJson,
  }) {
    final result = GetPaymailResponse._();
    if (paymailJson != null) result.paymailJson = paymailJson;
    return result;
  }

  GetPaymailResponse._();

  factory GetPaymailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPaymailResponse()..mergeFromBuffer(data, registry);
  factory GetPaymailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPaymailResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPaymailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: GetPaymailResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'paymailJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPaymailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPaymailResponse copyWith(void Function(GetPaymailResponse) updates) =>
      super.copyWith((message) => updates(message as GetPaymailResponse)) as GetPaymailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPaymailResponse() / GetPaymailResponse.new instead')
  static GetPaymailResponse create() => GetPaymailResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPaymailResponse._();
  @$core.override
  GetPaymailResponse createEmptyInstance() => GetPaymailResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPaymailResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPaymailResponse>(GetPaymailResponse.$_createMessage);
  static GetPaymailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get paymailJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set paymailJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaymailJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaymailJson() => $_clearField(1);
}

class ResolveCommitRequest extends $pb.GeneratedMessage {
  factory ResolveCommitRequest({
    $core.String? bitname,
  }) {
    final result = ResolveCommitRequest._();
    if (bitname != null) result.bitname = bitname;
    return result;
  }

  ResolveCommitRequest._();

  factory ResolveCommitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveCommitRequest()..mergeFromBuffer(data, registry);
  factory ResolveCommitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveCommitRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResolveCommitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ResolveCommitRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bitname')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveCommitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveCommitRequest copyWith(void Function(ResolveCommitRequest) updates) =>
      super.copyWith((message) => updates(message as ResolveCommitRequest)) as ResolveCommitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResolveCommitRequest() / ResolveCommitRequest.new instead')
  static ResolveCommitRequest create() => ResolveCommitRequest._();
  static $pb.GeneratedMessage $_createMessage() => ResolveCommitRequest._();
  @$core.override
  ResolveCommitRequest createEmptyInstance() => ResolveCommitRequest._();
  @$core.pragma('dart2js:noInline')
  static ResolveCommitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveCommitRequest>(ResolveCommitRequest.$_createMessage);
  static ResolveCommitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bitname => $_getSZ(0);
  @$pb.TagNumber(1)
  set bitname($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBitname() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitname() => $_clearField(1);
}

class ResolveCommitResponse extends $pb.GeneratedMessage {
  factory ResolveCommitResponse({
    $core.String? commitment,
    $core.String? dataJson,
    $core.bool? matches,
  }) {
    final result = ResolveCommitResponse._();
    if (commitment != null) result.commitment = commitment;
    if (dataJson != null) result.dataJson = dataJson;
    if (matches != null) result.matches = matches;
    return result;
  }

  ResolveCommitResponse._();

  factory ResolveCommitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveCommitResponse()..mergeFromBuffer(data, registry);
  factory ResolveCommitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResolveCommitResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResolveCommitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ResolveCommitResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'commitment')
    ..aOS(2, _omitFieldNames ? '' : 'dataJson')
    ..aOB(3, _omitFieldNames ? '' : 'matches')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveCommitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveCommitResponse copyWith(void Function(ResolveCommitResponse) updates) =>
      super.copyWith((message) => updates(message as ResolveCommitResponse)) as ResolveCommitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResolveCommitResponse() / ResolveCommitResponse.new instead')
  static ResolveCommitResponse create() => ResolveCommitResponse._();
  static $pb.GeneratedMessage $_createMessage() => ResolveCommitResponse._();
  @$core.override
  ResolveCommitResponse createEmptyInstance() => ResolveCommitResponse._();
  @$core.pragma('dart2js:noInline')
  static ResolveCommitResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveCommitResponse>(ResolveCommitResponse.$_createMessage);
  static ResolveCommitResponse? _defaultInstance;

  /// The commitment the BitName holds on chain.
  @$pb.TagNumber(1)
  $core.String get commitment => $_getSZ(0);
  @$pb.TagNumber(1)
  set commitment($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitment() => $_clearField(1);

  /// The JSON object the address served.
  @$pb.TagNumber(2)
  $core.String get dataJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataJson() => $_clearField(2);

  /// True when data_json hashes to commitment.
  @$pb.TagNumber(3)
  $core.bool get matches => $_getBF(2);
  @$pb.TagNumber(3)
  set matches($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMatches() => $_has(2);
  @$pb.TagNumber(3)
  void clearMatches() => $_clearField(3);
}

class ReadCommitmentRequest extends $pb.GeneratedMessage {
  factory ReadCommitmentRequest({
    $core.String? address,
  }) {
    final result = ReadCommitmentRequest._();
    if (address != null) result.address = address;
    return result;
  }

  ReadCommitmentRequest._();

  factory ReadCommitmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReadCommitmentRequest()..mergeFromBuffer(data, registry);
  factory ReadCommitmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReadCommitmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReadCommitmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ReadCommitmentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadCommitmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadCommitmentRequest copyWith(void Function(ReadCommitmentRequest) updates) =>
      super.copyWith((message) => updates(message as ReadCommitmentRequest)) as ReadCommitmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReadCommitmentRequest() / ReadCommitmentRequest.new instead')
  static ReadCommitmentRequest create() => ReadCommitmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReadCommitmentRequest._();
  @$core.override
  ReadCommitmentRequest createEmptyInstance() => ReadCommitmentRequest._();
  @$core.pragma('dart2js:noInline')
  static ReadCommitmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadCommitmentRequest>(ReadCommitmentRequest.$_createMessage);
  static ReadCommitmentRequest? _defaultInstance;

  /// Socket address, as host:port.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class ReadCommitmentResponse extends $pb.GeneratedMessage {
  factory ReadCommitmentResponse({
    $core.String? dataJson,
    $core.String? commitment,
    $core.String? socketAddrV4,
    $core.String? socketAddrV6,
  }) {
    final result = ReadCommitmentResponse._();
    if (dataJson != null) result.dataJson = dataJson;
    if (commitment != null) result.commitment = commitment;
    if (socketAddrV4 != null) result.socketAddrV4 = socketAddrV4;
    if (socketAddrV6 != null) result.socketAddrV6 = socketAddrV6;
    return result;
  }

  ReadCommitmentResponse._();

  factory ReadCommitmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReadCommitmentResponse()..mergeFromBuffer(data, registry);
  factory ReadCommitmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReadCommitmentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReadCommitmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: ReadCommitmentResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dataJson')
    ..aOS(2, _omitFieldNames ? '' : 'commitment')
    ..aOS(3, _omitFieldNames ? '' : 'socketAddrV4')
    ..aOS(4, _omitFieldNames ? '' : 'socketAddrV6')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadCommitmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadCommitmentResponse copyWith(void Function(ReadCommitmentResponse) updates) =>
      super.copyWith((message) => updates(message as ReadCommitmentResponse)) as ReadCommitmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReadCommitmentResponse() / ReadCommitmentResponse.new instead')
  static ReadCommitmentResponse create() => ReadCommitmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReadCommitmentResponse._();
  @$core.override
  ReadCommitmentResponse createEmptyInstance() => ReadCommitmentResponse._();
  @$core.pragma('dart2js:noInline')
  static ReadCommitmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadCommitmentResponse>(ReadCommitmentResponse.$_createMessage);
  static ReadCommitmentResponse? _defaultInstance;

  /// The JSON object the address served.
  @$pb.TagNumber(1)
  $core.String get dataJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataJson() => $_clearField(1);

  /// BLAKE3 digest of the canonical form of data_json.
  @$pb.TagNumber(2)
  $core.String get commitment => $_getSZ(1);
  @$pb.TagNumber(2)
  set commitment($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommitment() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommitment() => $_clearField(2);

  /// The ipv4 address the host resolves to, as host:port. Empty when the host
  /// has no ipv4 address. A BitName holds this address, not the host.
  @$pb.TagNumber(3)
  $core.String get socketAddrV4 => $_getSZ(2);
  @$pb.TagNumber(3)
  set socketAddrV4($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSocketAddrV4() => $_has(2);
  @$pb.TagNumber(3)
  void clearSocketAddrV4() => $_clearField(3);

  /// The ipv6 address the host resolves to, as host:port. Empty when the host
  /// has no ipv6 address.
  @$pb.TagNumber(4)
  $core.String get socketAddrV6 => $_getSZ(3);
  @$pb.TagNumber(4)
  set socketAddrV6($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSocketAddrV6() => $_has(3);
  @$pb.TagNumber(4)
  void clearSocketAddrV6() => $_clearField(4);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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

class MyUtxosRequest extends $pb.GeneratedMessage {
  factory MyUtxosRequest() => MyUtxosRequest._();

  MyUtxosRequest._();

  factory MyUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUtxosRequest()..mergeFromBuffer(data, registry);
  factory MyUtxosRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: MyUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUtxosRequest copyWith(void Function(MyUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as MyUtxosRequest)) as MyUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MyUtxosRequest() / MyUtxosRequest.new instead')
  static MyUtxosRequest create() => MyUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => MyUtxosRequest._();
  @$core.override
  MyUtxosRequest createEmptyInstance() => MyUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static MyUtxosRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUtxosRequest>(MyUtxosRequest.$_createMessage);
  static MyUtxosRequest? _defaultInstance;
}

class MyUtxosResponse extends $pb.GeneratedMessage {
  factory MyUtxosResponse({
    $core.String? utxosJson,
  }) {
    final result = MyUtxosResponse._();
    if (utxosJson != null) result.utxosJson = utxosJson;
    return result;
  }

  MyUtxosResponse._();

  factory MyUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUtxosResponse()..mergeFromBuffer(data, registry);
  factory MyUtxosResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
      createEmptyInstance: MyUtxosResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'utxosJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyUtxosResponse copyWith(void Function(MyUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as MyUtxosResponse)) as MyUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MyUtxosResponse() / MyUtxosResponse.new instead')
  static MyUtxosResponse create() => MyUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => MyUtxosResponse._();
  @$core.override
  MyUtxosResponse createEmptyInstance() => MyUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static MyUtxosResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyUtxosResponse>(MyUtxosResponse.$_createMessage);
  static MyUtxosResponse? _defaultInstance;

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitnames.v1'),
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

class BitnamesServiceApi {
  final $pb.RpcClient _client;

  BitnamesServiceApi(this._client);

  /// Get wallet balance (total and available).
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'BitnamesService', 'GetBalance', request, GetBalanceResponse());

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'BitnamesService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Stop the bitnames node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'BitnamesService', 'Stop', request, StopResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'BitnamesService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Withdraw to mainchain.
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
      _client.invoke<WithdrawResponse>(ctx, 'BitnamesService', 'Withdraw', request, WithdrawResponse());

  /// Transfer within sidechain.
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
      _client.invoke<TransferResponse>(ctx, 'BitnamesService', 'Transfer', request, TransferResponse());

  /// Get total sidechain wealth in sats.
  $async.Future<GetSidechainWealthResponse> getSidechainWealth(
          $pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
      _client.invoke<GetSidechainWealthResponse>(
          ctx, 'BitnamesService', 'GetSidechainWealth', request, GetSidechainWealthResponse());

  /// Create a deposit transaction.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
      _client.invoke<CreateDepositResponse>(ctx, 'BitnamesService', 'CreateDeposit', request, CreateDepositResponse());

  /// Get pending withdrawal bundle.
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
          $pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
      _client.invoke<GetPendingWithdrawalBundleResponse>(
          ctx, 'BitnamesService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse());

  /// Connect to a peer.
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
      _client.invoke<ConnectPeerResponse>(ctx, 'BitnamesService', 'ConnectPeer', request, ConnectPeerResponse());

  /// List connected peers.
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
      _client.invoke<ListPeersResponse>(ctx, 'BitnamesService', 'ListPeers', request, ListPeersResponse());

  /// Mine a block.
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
      _client.invoke<MineResponse>(ctx, 'BitnamesService', 'Mine', request, MineResponse());

  /// Get block by hash.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'BitnamesService', 'GetBlock', request, GetBlockResponse());

  /// Get best mainchain block hash.
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
          $pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
      _client.invoke<GetBestMainchainBlockHashResponse>(
          ctx, 'BitnamesService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse());

  /// Get best sidechain block hash.
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
          $pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
      _client.invoke<GetBestSidechainBlockHashResponse>(
          ctx, 'BitnamesService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse());

  /// Get BMM inclusions for a block.
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
      _client.invoke<GetBmmInclusionsResponse>(
          ctx, 'BitnamesService', 'GetBmmInclusions', request, GetBmmInclusionsResponse());

  /// Get wallet UTXOs.
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) => _client
      .invoke<GetWalletUtxosResponse>(ctx, 'BitnamesService', 'GetWalletUtxos', request, GetWalletUtxosResponse());

  /// List all UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'BitnamesService', 'ListUtxos', request, ListUtxosResponse());

  /// Get latest failed withdrawal bundle height.
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
          $pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
      _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'BitnamesService',
          'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse());

  /// Generate a new mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'BitnamesService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// Set seed from mnemonic.
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic(
          $pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
      _client.invoke<SetSeedFromMnemonicResponse>(
          ctx, 'BitnamesService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse());

  /// Raw JSON-RPC passthrough for debug console.
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
      _client.invoke<CallRawResponse>(ctx, 'BitnamesService', 'CallRaw', request, CallRawResponse());

  /// Get BitName data by name.
  $async.Future<GetBitNameDataResponse> getBitNameData($pb.ClientContext? ctx, GetBitNameDataRequest request) => _client
      .invoke<GetBitNameDataResponse>(ctx, 'BitnamesService', 'GetBitNameData', request, GetBitNameDataResponse());

  /// List all BitNames.
  $async.Future<ListBitNamesResponse> listBitNames($pb.ClientContext? ctx, ListBitNamesRequest request) =>
      _client.invoke<ListBitNamesResponse>(ctx, 'BitnamesService', 'ListBitNames', request, ListBitNamesResponse());

  /// Register a BitName.
  $async.Future<RegisterBitNameResponse> registerBitName($pb.ClientContext? ctx, RegisterBitNameRequest request) =>
      _client.invoke<RegisterBitNameResponse>(
          ctx, 'BitnamesService', 'RegisterBitName', request, RegisterBitNameResponse());

  /// Reserve a BitName.
  $async.Future<ReserveBitNameResponse> reserveBitName($pb.ClientContext? ctx, ReserveBitNameRequest request) => _client
      .invoke<ReserveBitNameResponse>(ctx, 'BitnamesService', 'ReserveBitName', request, ReserveBitNameResponse());

  /// Get a new encryption key.
  $async.Future<GetNewEncryptionKeyResponse> getNewEncryptionKey(
          $pb.ClientContext? ctx, GetNewEncryptionKeyRequest request) =>
      _client.invoke<GetNewEncryptionKeyResponse>(
          ctx, 'BitnamesService', 'GetNewEncryptionKey', request, GetNewEncryptionKeyResponse());

  /// Get a new verifying key.
  $async.Future<GetNewVerifyingKeyResponse> getNewVerifyingKey(
          $pb.ClientContext? ctx, GetNewVerifyingKeyRequest request) =>
      _client.invoke<GetNewVerifyingKeyResponse>(
          ctx, 'BitnamesService', 'GetNewVerifyingKey', request, GetNewVerifyingKeyResponse());

  /// Decrypt a message.
  $async.Future<DecryptMsgResponse> decryptMsg($pb.ClientContext? ctx, DecryptMsgRequest request) =>
      _client.invoke<DecryptMsgResponse>(ctx, 'BitnamesService', 'DecryptMsg', request, DecryptMsgResponse());

  /// Encrypt a message.
  $async.Future<EncryptMsgResponse> encryptMsg($pb.ClientContext? ctx, EncryptMsgRequest request) =>
      _client.invoke<EncryptMsgResponse>(ctx, 'BitnamesService', 'EncryptMsg', request, EncryptMsgResponse());

  /// Get paymail information.
  $async.Future<GetPaymailResponse> getPaymail($pb.ClientContext? ctx, GetPaymailRequest request) =>
      _client.invoke<GetPaymailResponse>(ctx, 'BitnamesService', 'GetPaymail', request, GetPaymailResponse());

  /// Read the messages that wait in the mempool. A message reaches a BitName
  /// one block before GetPaymail reports it, so a chat reads both.
  $async.Future<GetPendingPaymailResponse> getPendingPaymail(
          $pb.ClientContext? ctx, GetPendingPaymailRequest request) =>
      _client.invoke<GetPendingPaymailResponse>(
          ctx, 'BitnamesService', 'GetPendingPaymail', request, GetPendingPaymailResponse());

  /// Read the address that holds a BitName. A message pays the holder.
  $async.Future<GetBitNameOwnerResponse> getBitNameOwner($pb.ClientContext? ctx, GetBitNameOwnerRequest request) =>
      _client.invoke<GetBitNameOwnerResponse>(
          ctx, 'BitnamesService', 'GetBitNameOwner', request, GetBitNameOwnerResponse());

  /// Resolve a commitment from a BitName.
  $async.Future<ResolveCommitResponse> resolveCommit($pb.ClientContext? ctx, ResolveCommitRequest request) =>
      _client.invoke<ResolveCommitResponse>(ctx, 'BitnamesService', 'ResolveCommit', request, ResolveCommitResponse());

  /// Read a data commitment from an address, before a BitName holds it.
  $async.Future<ReadCommitmentResponse> readCommitment($pb.ClientContext? ctx, ReadCommitmentRequest request) => _client
      .invoke<ReadCommitmentResponse>(ctx, 'BitnamesService', 'ReadCommitment', request, ReadCommitmentResponse());

  /// Sign an arbitrary message with the specified verifying key.
  $async.Future<SignArbitraryMsgResponse> signArbitraryMsg($pb.ClientContext? ctx, SignArbitraryMsgRequest request) =>
      _client.invoke<SignArbitraryMsgResponse>(
          ctx, 'BitnamesService', 'SignArbitraryMsg', request, SignArbitraryMsgResponse());

  /// Sign an arbitrary message as a specific address.
  $async.Future<SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
          $pb.ClientContext? ctx, SignArbitraryMsgAsAddrRequest request) =>
      _client.invoke<SignArbitraryMsgAsAddrResponse>(
          ctx, 'BitnamesService', 'SignArbitraryMsgAsAddr', request, SignArbitraryMsgAsAddrResponse());

  /// Get wallet addresses.
  $async.Future<GetWalletAddressesResponse> getWalletAddresses(
          $pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
      _client.invoke<GetWalletAddressesResponse>(
          ctx, 'BitnamesService', 'GetWalletAddresses', request, GetWalletAddressesResponse());

  /// List owned UTXOs.
  $async.Future<MyUtxosResponse> myUtxos($pb.ClientContext? ctx, MyUtxosRequest request) =>
      _client.invoke<MyUtxosResponse>(ctx, 'BitnamesService', 'MyUtxos', request, MyUtxosResponse());

  /// Get OpenAPI schema.
  $async.Future<OpenapiSchemaResponse> openapiSchema($pb.ClientContext? ctx, OpenapiSchemaRequest request) =>
      _client.invoke<OpenapiSchemaResponse>(ctx, 'BitnamesService', 'OpenapiSchema', request, OpenapiSchemaResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
