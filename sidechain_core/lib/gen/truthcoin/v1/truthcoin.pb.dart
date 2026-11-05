// This is a generated file - do not edit.
//
// Generated from truthcoin/v1/truthcoin.proto.

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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

class RefreshWalletRequest extends $pb.GeneratedMessage {
  factory RefreshWalletRequest() => RefreshWalletRequest._();

  RefreshWalletRequest._();

  factory RefreshWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshWalletRequest()..mergeFromBuffer(data, registry);
  factory RefreshWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: RefreshWalletRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshWalletRequest copyWith(void Function(RefreshWalletRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshWalletRequest)) as RefreshWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RefreshWalletRequest() / RefreshWalletRequest.new instead')
  static RefreshWalletRequest create() => RefreshWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => RefreshWalletRequest._();
  @$core.override
  RefreshWalletRequest createEmptyInstance() => RefreshWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static RefreshWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshWalletRequest>(RefreshWalletRequest.$_createMessage);
  static RefreshWalletRequest? _defaultInstance;
}

class RefreshWalletResponse extends $pb.GeneratedMessage {
  factory RefreshWalletResponse() => RefreshWalletResponse._();

  RefreshWalletResponse._();

  factory RefreshWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshWalletResponse()..mergeFromBuffer(data, registry);
  factory RefreshWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: RefreshWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshWalletResponse copyWith(void Function(RefreshWalletResponse) updates) =>
      super.copyWith((message) => updates(message as RefreshWalletResponse)) as RefreshWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RefreshWalletResponse() / RefreshWalletResponse.new instead')
  static RefreshWalletResponse create() => RefreshWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => RefreshWalletResponse._();
  @$core.override
  RefreshWalletResponse createEmptyInstance() => RefreshWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static RefreshWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshWalletResponse>(RefreshWalletResponse.$_createMessage);
  static RefreshWalletResponse? _defaultInstance;
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? txid,
  }) {
    final result = GetTransactionRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionRequest._();

  factory GetTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest copyWith(void Function(GetTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionRequest)) as GetTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionRequest() / GetTransactionRequest.new instead')
  static GetTransactionRequest create() => GetTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionRequest._();
  @$core.override
  GetTransactionRequest createEmptyInstance() => GetTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(GetTransactionRequest.$_createMessage);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    $core.String? transactionJson,
  }) {
    final result = GetTransactionResponse._();
    if (transactionJson != null) result.transactionJson = transactionJson;
    return result;
  }

  GetTransactionResponse._();

  factory GetTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse()..mergeFromBuffer(data, registry);
  factory GetTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'transactionJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse copyWith(void Function(GetTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionResponse)) as GetTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionResponse() / GetTransactionResponse.new instead')
  static GetTransactionResponse create() => GetTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionResponse._();
  @$core.override
  GetTransactionResponse createEmptyInstance() => GetTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(GetTransactionResponse.$_createMessage);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransactionJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionJson() => $_clearField(1);
}

class GetTransactionInfoRequest extends $pb.GeneratedMessage {
  factory GetTransactionInfoRequest({
    $core.String? txid,
  }) {
    final result = GetTransactionInfoRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionInfoRequest._();

  factory GetTransactionInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionInfoRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetTransactionInfoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionInfoRequest copyWith(void Function(GetTransactionInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionInfoRequest)) as GetTransactionInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionInfoRequest() / GetTransactionInfoRequest.new instead')
  static GetTransactionInfoRequest create() => GetTransactionInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionInfoRequest._();
  @$core.override
  GetTransactionInfoRequest createEmptyInstance() => GetTransactionInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionInfoRequest>(GetTransactionInfoRequest.$_createMessage);
  static GetTransactionInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetTransactionInfoResponse extends $pb.GeneratedMessage {
  factory GetTransactionInfoResponse({
    $core.String? transactionInfoJson,
  }) {
    final result = GetTransactionInfoResponse._();
    if (transactionInfoJson != null) result.transactionInfoJson = transactionInfoJson;
    return result;
  }

  GetTransactionInfoResponse._();

  factory GetTransactionInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionInfoResponse()..mergeFromBuffer(data, registry);
  factory GetTransactionInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetTransactionInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'transactionInfoJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionInfoResponse copyWith(void Function(GetTransactionInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionInfoResponse)) as GetTransactionInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionInfoResponse() / GetTransactionInfoResponse.new instead')
  static GetTransactionInfoResponse create() => GetTransactionInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionInfoResponse._();
  @$core.override
  GetTransactionInfoResponse createEmptyInstance() => GetTransactionInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionInfoResponse>(GetTransactionInfoResponse.$_createMessage);
  static GetTransactionInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transactionInfoJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionInfoJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransactionInfoJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionInfoJson() => $_clearField(1);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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

class CalculateInitialLiquidityRequest extends $pb.GeneratedMessage {
  factory CalculateInitialLiquidityRequest({
    $core.double? beta,
    $core.int? numOutcomes,
    $core.String? dimensions,
  }) {
    final result = CalculateInitialLiquidityRequest._();
    if (beta != null) result.beta = beta;
    if (numOutcomes != null) result.numOutcomes = numOutcomes;
    if (dimensions != null) result.dimensions = dimensions;
    return result;
  }

  CalculateInitialLiquidityRequest._();

  factory CalculateInitialLiquidityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateInitialLiquidityRequest()..mergeFromBuffer(data, registry);
  factory CalculateInitialLiquidityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateInitialLiquidityRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateInitialLiquidityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: CalculateInitialLiquidityRequest.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'beta')
    ..aI(2, _omitFieldNames ? '' : 'numOutcomes')
    ..aOS(3, _omitFieldNames ? '' : 'dimensions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateInitialLiquidityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateInitialLiquidityRequest copyWith(void Function(CalculateInitialLiquidityRequest) updates) =>
      super.copyWith((message) => updates(message as CalculateInitialLiquidityRequest))
          as CalculateInitialLiquidityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalculateInitialLiquidityRequest() / CalculateInitialLiquidityRequest.new instead')
  static CalculateInitialLiquidityRequest create() => CalculateInitialLiquidityRequest._();
  static $pb.GeneratedMessage $_createMessage() => CalculateInitialLiquidityRequest._();
  @$core.override
  CalculateInitialLiquidityRequest createEmptyInstance() => CalculateInitialLiquidityRequest._();
  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateInitialLiquidityRequest>(
          CalculateInitialLiquidityRequest.$_createMessage);
  static CalculateInitialLiquidityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get beta => $_getN(0);
  @$pb.TagNumber(1)
  set beta($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBeta() => $_has(0);
  @$pb.TagNumber(1)
  void clearBeta() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get numOutcomes => $_getIZ(1);
  @$pb.TagNumber(2)
  set numOutcomes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumOutcomes() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumOutcomes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dimensions => $_getSZ(2);
  @$pb.TagNumber(3)
  set dimensions($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDimensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearDimensions() => $_clearField(3);
}

class CalculateInitialLiquidityResponse extends $pb.GeneratedMessage {
  factory CalculateInitialLiquidityResponse({
    $core.String? resultJson,
  }) {
    final result = CalculateInitialLiquidityResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  CalculateInitialLiquidityResponse._();

  factory CalculateInitialLiquidityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateInitialLiquidityResponse()..mergeFromBuffer(data, registry);
  factory CalculateInitialLiquidityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateInitialLiquidityResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateInitialLiquidityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: CalculateInitialLiquidityResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateInitialLiquidityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateInitialLiquidityResponse copyWith(void Function(CalculateInitialLiquidityResponse) updates) =>
      super.copyWith((message) => updates(message as CalculateInitialLiquidityResponse))
          as CalculateInitialLiquidityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalculateInitialLiquidityResponse() / CalculateInitialLiquidityResponse.new instead')
  static CalculateInitialLiquidityResponse create() => CalculateInitialLiquidityResponse._();
  static $pb.GeneratedMessage $_createMessage() => CalculateInitialLiquidityResponse._();
  @$core.override
  CalculateInitialLiquidityResponse createEmptyInstance() => CalculateInitialLiquidityResponse._();
  @$core.pragma('dart2js:noInline')
  static CalculateInitialLiquidityResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateInitialLiquidityResponse>(
          CalculateInitialLiquidityResponse.$_createMessage);
  static CalculateInitialLiquidityResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
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
    $fixnum.Int64? maxListingFeeSats,
  }) {
    final result = MarketCreateRequest._();
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (dimensions != null) result.dimensions = dimensions;
    if (feeSats != null) result.feeSats = feeSats;
    if (beta != null) result.beta = beta;
    if (initialLiquidity != null) result.initialLiquidity = initialLiquidity;
    if (tradingFee != null) result.tradingFee = tradingFee;
    if (tags != null) result.tags.addAll(tags);
    if (categoryTxids != null) result.categoryTxids.addAll(categoryTxids);
    if (residualNames != null) result.residualNames.addAll(residualNames);
    if (maxListingFeeSats != null) result.maxListingFeeSats = maxListingFeeSats;
    return result;
  }

  MarketCreateRequest._();

  factory MarketCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketCreateRequest()..mergeFromBuffer(data, registry);
  factory MarketCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'dimensions')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..aD(5, _omitFieldNames ? '' : 'beta')
    ..aInt64(6, _omitFieldNames ? '' : 'initialLiquidity')
    ..aD(7, _omitFieldNames ? '' : 'tradingFee')
    ..pPS(8, _omitFieldNames ? '' : 'tags')
    ..pPS(9, _omitFieldNames ? '' : 'categoryTxids')
    ..pPS(10, _omitFieldNames ? '' : 'residualNames')
    ..aInt64(11, _omitFieldNames ? '' : 'maxListingFeeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCreateRequest copyWith(void Function(MarketCreateRequest) updates) =>
      super.copyWith((message) => updates(message as MarketCreateRequest)) as MarketCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketCreateRequest() / MarketCreateRequest.new instead')
  static MarketCreateRequest create() => MarketCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketCreateRequest._();
  @$core.override
  MarketCreateRequest createEmptyInstance() => MarketCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketCreateRequest>(MarketCreateRequest.$_createMessage);
  static MarketCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dimensions => $_getSZ(2);
  @$pb.TagNumber(3)
  set dimensions($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDimensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearDimensions() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get beta => $_getN(4);
  @$pb.TagNumber(5)
  set beta($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBeta() => $_has(4);
  @$pb.TagNumber(5)
  void clearBeta() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get initialLiquidity => $_getI64(5);
  @$pb.TagNumber(6)
  set initialLiquidity($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInitialLiquidity() => $_has(5);
  @$pb.TagNumber(6)
  void clearInitialLiquidity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get tradingFee => $_getN(6);
  @$pb.TagNumber(7)
  set tradingFee($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTradingFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearTradingFee() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get tags => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get categoryTxids => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get residualNames => $_getList(9);

  @$pb.TagNumber(11)
  $fixnum.Int64 get maxListingFeeSats => $_getI64(10);
  @$pb.TagNumber(11)
  set maxListingFeeSats($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMaxListingFeeSats() => $_has(10);
  @$pb.TagNumber(11)
  void clearMaxListingFeeSats() => $_clearField(11);
}

class MarketCreateResponse extends $pb.GeneratedMessage {
  factory MarketCreateResponse({
    $core.String? txid,
  }) {
    final result = MarketCreateResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  MarketCreateResponse._();

  factory MarketCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketCreateResponse()..mergeFromBuffer(data, registry);
  factory MarketCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketCreateResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketCreateResponse copyWith(void Function(MarketCreateResponse) updates) =>
      super.copyWith((message) => updates(message as MarketCreateResponse)) as MarketCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketCreateResponse() / MarketCreateResponse.new instead')
  static MarketCreateResponse create() => MarketCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketCreateResponse._();
  @$core.override
  MarketCreateResponse createEmptyInstance() => MarketCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketCreateResponse>(MarketCreateResponse.$_createMessage);
  static MarketCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class MarketListRequest extends $pb.GeneratedMessage {
  factory MarketListRequest() => MarketListRequest._();

  MarketListRequest._();

  factory MarketListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketListRequest()..mergeFromBuffer(data, registry);
  factory MarketListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketListRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketListRequest copyWith(void Function(MarketListRequest) updates) =>
      super.copyWith((message) => updates(message as MarketListRequest)) as MarketListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketListRequest() / MarketListRequest.new instead')
  static MarketListRequest create() => MarketListRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketListRequest._();
  @$core.override
  MarketListRequest createEmptyInstance() => MarketListRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketListRequest>(MarketListRequest.$_createMessage);
  static MarketListRequest? _defaultInstance;
}

class MarketListResponse extends $pb.GeneratedMessage {
  factory MarketListResponse({
    $core.String? marketsJson,
  }) {
    final result = MarketListResponse._();
    if (marketsJson != null) result.marketsJson = marketsJson;
    return result;
  }

  MarketListResponse._();

  factory MarketListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketListResponse()..mergeFromBuffer(data, registry);
  factory MarketListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketListResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketListResponse copyWith(void Function(MarketListResponse) updates) =>
      super.copyWith((message) => updates(message as MarketListResponse)) as MarketListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketListResponse() / MarketListResponse.new instead')
  static MarketListResponse create() => MarketListResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketListResponse._();
  @$core.override
  MarketListResponse createEmptyInstance() => MarketListResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketListResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketListResponse>(MarketListResponse.$_createMessage);
  static MarketListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketsJson() => $_clearField(1);
}

class MarketGetRequest extends $pb.GeneratedMessage {
  factory MarketGetRequest({
    $core.String? marketId,
  }) {
    final result = MarketGetRequest._();
    if (marketId != null) result.marketId = marketId;
    return result;
  }

  MarketGetRequest._();

  factory MarketGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketGetRequest()..mergeFromBuffer(data, registry);
  factory MarketGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketGetRequest copyWith(void Function(MarketGetRequest) updates) =>
      super.copyWith((message) => updates(message as MarketGetRequest)) as MarketGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketGetRequest() / MarketGetRequest.new instead')
  static MarketGetRequest create() => MarketGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketGetRequest._();
  @$core.override
  MarketGetRequest createEmptyInstance() => MarketGetRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketGetRequest>(MarketGetRequest.$_createMessage);
  static MarketGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => $_clearField(1);
}

class MarketGetResponse extends $pb.GeneratedMessage {
  factory MarketGetResponse({
    $core.String? marketJson,
  }) {
    final result = MarketGetResponse._();
    if (marketJson != null) result.marketJson = marketJson;
    return result;
  }

  MarketGetResponse._();

  factory MarketGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketGetResponse()..mergeFromBuffer(data, registry);
  factory MarketGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketGetResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketGetResponse copyWith(void Function(MarketGetResponse) updates) =>
      super.copyWith((message) => updates(message as MarketGetResponse)) as MarketGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketGetResponse() / MarketGetResponse.new instead')
  static MarketGetResponse create() => MarketGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketGetResponse._();
  @$core.override
  MarketGetResponse createEmptyInstance() => MarketGetResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketGetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketGetResponse>(MarketGetResponse.$_createMessage);
  static MarketGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketJson() => $_clearField(1);
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
    final result = MarketBuyRequest._();
    if (marketId != null) result.marketId = marketId;
    if (outcomeIndex != null) result.outcomeIndex = outcomeIndex;
    if (sharesAmount != null) result.sharesAmount = sharesAmount;
    if (dryRun != null) result.dryRun = dryRun;
    if (feeSats != null) result.feeSats = feeSats;
    if (maxCost != null) result.maxCost = maxCost;
    return result;
  }

  MarketBuyRequest._();

  factory MarketBuyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyRequest()..mergeFromBuffer(data, registry);
  factory MarketBuyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketBuyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketBuyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..aI(2, _omitFieldNames ? '' : 'outcomeIndex')
    ..aD(3, _omitFieldNames ? '' : 'sharesAmount')
    ..aOB(4, _omitFieldNames ? '' : 'dryRun')
    ..aInt64(5, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(6, _omitFieldNames ? '' : 'maxCost')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyRequest copyWith(void Function(MarketBuyRequest) updates) =>
      super.copyWith((message) => updates(message as MarketBuyRequest)) as MarketBuyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketBuyRequest() / MarketBuyRequest.new instead')
  static MarketBuyRequest create() => MarketBuyRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketBuyRequest._();
  @$core.override
  MarketBuyRequest createEmptyInstance() => MarketBuyRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketBuyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketBuyRequest>(MarketBuyRequest.$_createMessage);
  static MarketBuyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get outcomeIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outcomeIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutcomeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutcomeIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get sharesAmount => $_getN(2);
  @$pb.TagNumber(3)
  set sharesAmount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSharesAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSharesAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get dryRun => $_getBF(3);
  @$pb.TagNumber(4)
  set dryRun($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDryRun() => $_has(3);
  @$pb.TagNumber(4)
  void clearDryRun() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get maxCost => $_getI64(5);
  @$pb.TagNumber(6)
  set maxCost($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxCost() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxCost() => $_clearField(6);
}

class MarketBuyResponse extends $pb.GeneratedMessage {
  factory MarketBuyResponse({
    $core.String? resultJson,
  }) {
    final result = MarketBuyResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  MarketBuyResponse._();

  factory MarketBuyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyResponse()..mergeFromBuffer(data, registry);
  factory MarketBuyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketBuyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketBuyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyResponse copyWith(void Function(MarketBuyResponse) updates) =>
      super.copyWith((message) => updates(message as MarketBuyResponse)) as MarketBuyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketBuyResponse() / MarketBuyResponse.new instead')
  static MarketBuyResponse create() => MarketBuyResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketBuyResponse._();
  @$core.override
  MarketBuyResponse createEmptyInstance() => MarketBuyResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketBuyResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketBuyResponse>(MarketBuyResponse.$_createMessage);
  static MarketBuyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
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
    final result = MarketSellRequest._();
    if (marketId != null) result.marketId = marketId;
    if (outcomeIndex != null) result.outcomeIndex = outcomeIndex;
    if (sharesAmount != null) result.sharesAmount = sharesAmount;
    if (sellerAddress != null) result.sellerAddress = sellerAddress;
    if (dryRun != null) result.dryRun = dryRun;
    if (feeSats != null) result.feeSats = feeSats;
    if (minProceeds != null) result.minProceeds = minProceeds;
    return result;
  }

  MarketSellRequest._();

  factory MarketSellRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellRequest()..mergeFromBuffer(data, registry);
  factory MarketSellRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketSellRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketSellRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..aI(2, _omitFieldNames ? '' : 'outcomeIndex')
    ..aInt64(3, _omitFieldNames ? '' : 'sharesAmount')
    ..aOS(4, _omitFieldNames ? '' : 'sellerAddress')
    ..aOB(5, _omitFieldNames ? '' : 'dryRun')
    ..aInt64(6, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(7, _omitFieldNames ? '' : 'minProceeds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellRequest copyWith(void Function(MarketSellRequest) updates) =>
      super.copyWith((message) => updates(message as MarketSellRequest)) as MarketSellRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketSellRequest() / MarketSellRequest.new instead')
  static MarketSellRequest create() => MarketSellRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketSellRequest._();
  @$core.override
  MarketSellRequest createEmptyInstance() => MarketSellRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketSellRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketSellRequest>(MarketSellRequest.$_createMessage);
  static MarketSellRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get outcomeIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outcomeIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutcomeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutcomeIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sharesAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set sharesAmount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSharesAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSharesAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sellerAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set sellerAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSellerAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearSellerAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get dryRun => $_getBF(4);
  @$pb.TagNumber(5)
  set dryRun($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDryRun() => $_has(4);
  @$pb.TagNumber(5)
  void clearDryRun() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get feeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSats() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get minProceeds => $_getI64(6);
  @$pb.TagNumber(7)
  set minProceeds($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMinProceeds() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinProceeds() => $_clearField(7);
}

class MarketSellResponse extends $pb.GeneratedMessage {
  factory MarketSellResponse({
    $core.String? resultJson,
  }) {
    final result = MarketSellResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  MarketSellResponse._();

  factory MarketSellResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellResponse()..mergeFromBuffer(data, registry);
  factory MarketSellResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketSellResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketSellResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellResponse copyWith(void Function(MarketSellResponse) updates) =>
      super.copyWith((message) => updates(message as MarketSellResponse)) as MarketSellResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketSellResponse() / MarketSellResponse.new instead')
  static MarketSellResponse create() => MarketSellResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketSellResponse._();
  @$core.override
  MarketSellResponse createEmptyInstance() => MarketSellResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketSellResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketSellResponse>(MarketSellResponse.$_createMessage);
  static MarketSellResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
}

class MarketPositionsRequest extends $pb.GeneratedMessage {
  factory MarketPositionsRequest({
    $core.String? address,
    $core.String? marketId,
  }) {
    final result = MarketPositionsRequest._();
    if (address != null) result.address = address;
    if (marketId != null) result.marketId = marketId;
    return result;
  }

  MarketPositionsRequest._();

  factory MarketPositionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketPositionsRequest()..mergeFromBuffer(data, registry);
  factory MarketPositionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketPositionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketPositionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketPositionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketPositionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketPositionsRequest copyWith(void Function(MarketPositionsRequest) updates) =>
      super.copyWith((message) => updates(message as MarketPositionsRequest)) as MarketPositionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketPositionsRequest() / MarketPositionsRequest.new instead')
  static MarketPositionsRequest create() => MarketPositionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketPositionsRequest._();
  @$core.override
  MarketPositionsRequest createEmptyInstance() => MarketPositionsRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketPositionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketPositionsRequest>(MarketPositionsRequest.$_createMessage);
  static MarketPositionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);
}

class MarketPositionsResponse extends $pb.GeneratedMessage {
  factory MarketPositionsResponse({
    $core.String? positionsJson,
  }) {
    final result = MarketPositionsResponse._();
    if (positionsJson != null) result.positionsJson = positionsJson;
    return result;
  }

  MarketPositionsResponse._();

  factory MarketPositionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketPositionsResponse()..mergeFromBuffer(data, registry);
  factory MarketPositionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketPositionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketPositionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketPositionsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'positionsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketPositionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketPositionsResponse copyWith(void Function(MarketPositionsResponse) updates) =>
      super.copyWith((message) => updates(message as MarketPositionsResponse)) as MarketPositionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketPositionsResponse() / MarketPositionsResponse.new instead')
  static MarketPositionsResponse create() => MarketPositionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketPositionsResponse._();
  @$core.override
  MarketPositionsResponse createEmptyInstance() => MarketPositionsResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketPositionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketPositionsResponse>(MarketPositionsResponse.$_createMessage);
  static MarketPositionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get positionsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set positionsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPositionsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPositionsJson() => $_clearField(1);
}

class MarketAmplifyBetaRequest extends $pb.GeneratedMessage {
  factory MarketAmplifyBetaRequest({
    $core.String? marketId,
    $fixnum.Int64? amountSats,
  }) {
    final result = MarketAmplifyBetaRequest._();
    if (marketId != null) result.marketId = marketId;
    if (amountSats != null) result.amountSats = amountSats;
    return result;
  }

  MarketAmplifyBetaRequest._();

  factory MarketAmplifyBetaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketAmplifyBetaRequest()..mergeFromBuffer(data, registry);
  factory MarketAmplifyBetaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketAmplifyBetaRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketAmplifyBetaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketAmplifyBetaRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marketId')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketAmplifyBetaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketAmplifyBetaRequest copyWith(void Function(MarketAmplifyBetaRequest) updates) =>
      super.copyWith((message) => updates(message as MarketAmplifyBetaRequest)) as MarketAmplifyBetaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketAmplifyBetaRequest() / MarketAmplifyBetaRequest.new instead')
  static MarketAmplifyBetaRequest create() => MarketAmplifyBetaRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarketAmplifyBetaRequest._();
  @$core.override
  MarketAmplifyBetaRequest createEmptyInstance() => MarketAmplifyBetaRequest._();
  @$core.pragma('dart2js:noInline')
  static MarketAmplifyBetaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketAmplifyBetaRequest>(MarketAmplifyBetaRequest.$_createMessage);
  static MarketAmplifyBetaRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marketId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);
}

class MarketAmplifyBetaResponse extends $pb.GeneratedMessage {
  factory MarketAmplifyBetaResponse({
    $core.String? txid,
  }) {
    final result = MarketAmplifyBetaResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  MarketAmplifyBetaResponse._();

  factory MarketAmplifyBetaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketAmplifyBetaResponse()..mergeFromBuffer(data, registry);
  factory MarketAmplifyBetaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketAmplifyBetaResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarketAmplifyBetaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: MarketAmplifyBetaResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketAmplifyBetaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketAmplifyBetaResponse copyWith(void Function(MarketAmplifyBetaResponse) updates) =>
      super.copyWith((message) => updates(message as MarketAmplifyBetaResponse)) as MarketAmplifyBetaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketAmplifyBetaResponse() / MarketAmplifyBetaResponse.new instead')
  static MarketAmplifyBetaResponse create() => MarketAmplifyBetaResponse._();
  static $pb.GeneratedMessage $_createMessage() => MarketAmplifyBetaResponse._();
  @$core.override
  MarketAmplifyBetaResponse createEmptyInstance() => MarketAmplifyBetaResponse._();
  @$core.pragma('dart2js:noInline')
  static MarketAmplifyBetaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketAmplifyBetaResponse>(MarketAmplifyBetaResponse.$_createMessage);
  static MarketAmplifyBetaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class SlotStatusRequest extends $pb.GeneratedMessage {
  factory SlotStatusRequest() => SlotStatusRequest._();

  SlotStatusRequest._();

  factory SlotStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotStatusRequest()..mergeFromBuffer(data, registry);
  factory SlotStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotStatusRequest copyWith(void Function(SlotStatusRequest) updates) =>
      super.copyWith((message) => updates(message as SlotStatusRequest)) as SlotStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotStatusRequest() / SlotStatusRequest.new instead')
  static SlotStatusRequest create() => SlotStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => SlotStatusRequest._();
  @$core.override
  SlotStatusRequest createEmptyInstance() => SlotStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static SlotStatusRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotStatusRequest>(SlotStatusRequest.$_createMessage);
  static SlotStatusRequest? _defaultInstance;
}

class SlotStatusResponse extends $pb.GeneratedMessage {
  factory SlotStatusResponse({
    $core.String? statusJson,
  }) {
    final result = SlotStatusResponse._();
    if (statusJson != null) result.statusJson = statusJson;
    return result;
  }

  SlotStatusResponse._();

  factory SlotStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotStatusResponse()..mergeFromBuffer(data, registry);
  factory SlotStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotStatusResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'statusJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotStatusResponse copyWith(void Function(SlotStatusResponse) updates) =>
      super.copyWith((message) => updates(message as SlotStatusResponse)) as SlotStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotStatusResponse() / SlotStatusResponse.new instead')
  static SlotStatusResponse create() => SlotStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => SlotStatusResponse._();
  @$core.override
  SlotStatusResponse createEmptyInstance() => SlotStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static SlotStatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotStatusResponse>(SlotStatusResponse.$_createMessage);
  static SlotStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get statusJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set statusJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatusJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusJson() => $_clearField(1);
}

class SlotListRequest extends $pb.GeneratedMessage {
  factory SlotListRequest({
    $core.int? period,
    $core.String? status,
  }) {
    final result = SlotListRequest._();
    if (period != null) result.period = period;
    if (status != null) result.status = status;
    return result;
  }

  SlotListRequest._();

  factory SlotListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotListRequest()..mergeFromBuffer(data, registry);
  factory SlotListRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotListRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'period')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotListRequest copyWith(void Function(SlotListRequest) updates) =>
      super.copyWith((message) => updates(message as SlotListRequest)) as SlotListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotListRequest() / SlotListRequest.new instead')
  static SlotListRequest create() => SlotListRequest._();
  static $pb.GeneratedMessage $_createMessage() => SlotListRequest._();
  @$core.override
  SlotListRequest createEmptyInstance() => SlotListRequest._();
  @$core.pragma('dart2js:noInline')
  static SlotListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotListRequest>(SlotListRequest.$_createMessage);
  static SlotListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get period => $_getIZ(0);
  @$pb.TagNumber(1)
  set period($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeriod() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriod() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class SlotListResponse extends $pb.GeneratedMessage {
  factory SlotListResponse({
    $core.String? slotsJson,
  }) {
    final result = SlotListResponse._();
    if (slotsJson != null) result.slotsJson = slotsJson;
    return result;
  }

  SlotListResponse._();

  factory SlotListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotListResponse()..mergeFromBuffer(data, registry);
  factory SlotListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotListResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'slotsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotListResponse copyWith(void Function(SlotListResponse) updates) =>
      super.copyWith((message) => updates(message as SlotListResponse)) as SlotListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotListResponse() / SlotListResponse.new instead')
  static SlotListResponse create() => SlotListResponse._();
  static $pb.GeneratedMessage $_createMessage() => SlotListResponse._();
  @$core.override
  SlotListResponse createEmptyInstance() => SlotListResponse._();
  @$core.pragma('dart2js:noInline')
  static SlotListResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotListResponse>(SlotListResponse.$_createMessage);
  static SlotListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlotsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotsJson() => $_clearField(1);
}

class SlotGetRequest extends $pb.GeneratedMessage {
  factory SlotGetRequest({
    $core.String? slotId,
  }) {
    final result = SlotGetRequest._();
    if (slotId != null) result.slotId = slotId;
    return result;
  }

  SlotGetRequest._();

  factory SlotGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotGetRequest()..mergeFromBuffer(data, registry);
  factory SlotGetRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'slotId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotGetRequest copyWith(void Function(SlotGetRequest) updates) =>
      super.copyWith((message) => updates(message as SlotGetRequest)) as SlotGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotGetRequest() / SlotGetRequest.new instead')
  static SlotGetRequest create() => SlotGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SlotGetRequest._();
  @$core.override
  SlotGetRequest createEmptyInstance() => SlotGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SlotGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotGetRequest>(SlotGetRequest.$_createMessage);
  static SlotGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotId => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlotId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotId() => $_clearField(1);
}

class SlotGetResponse extends $pb.GeneratedMessage {
  factory SlotGetResponse({
    $core.String? slotJson,
  }) {
    final result = SlotGetResponse._();
    if (slotJson != null) result.slotJson = slotJson;
    return result;
  }

  SlotGetResponse._();

  factory SlotGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotGetResponse()..mergeFromBuffer(data, registry);
  factory SlotGetResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotGetResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'slotJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotGetResponse copyWith(void Function(SlotGetResponse) updates) =>
      super.copyWith((message) => updates(message as SlotGetResponse)) as SlotGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotGetResponse() / SlotGetResponse.new instead')
  static SlotGetResponse create() => SlotGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => SlotGetResponse._();
  @$core.override
  SlotGetResponse createEmptyInstance() => SlotGetResponse._();
  @$core.pragma('dart2js:noInline')
  static SlotGetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotGetResponse>(SlotGetResponse.$_createMessage);
  static SlotGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlotJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotJson() => $_clearField(1);
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
    final result = SlotClaimRequest._();
    if (feeSats != null) result.feeSats = feeSats;
    if (periodIndex != null) result.periodIndex = periodIndex;
    if (slotIndex != null) result.slotIndex = slotIndex;
    if (question != null) result.question = question;
    if (isStandard != null) result.isStandard = isStandard;
    if (isScaled != null) result.isScaled = isScaled;
    if (min != null) result.min = min;
    if (max != null) result.max = max;
    return result;
  }

  SlotClaimRequest._();

  factory SlotClaimRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimRequest()..mergeFromBuffer(data, registry);
  factory SlotClaimRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotClaimRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..aI(2, _omitFieldNames ? '' : 'periodIndex')
    ..aI(3, _omitFieldNames ? '' : 'slotIndex')
    ..aOS(4, _omitFieldNames ? '' : 'question')
    ..aOB(5, _omitFieldNames ? '' : 'isStandard')
    ..aOB(6, _omitFieldNames ? '' : 'isScaled')
    ..aI(7, _omitFieldNames ? '' : 'min')
    ..aI(8, _omitFieldNames ? '' : 'max')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimRequest copyWith(void Function(SlotClaimRequest) updates) =>
      super.copyWith((message) => updates(message as SlotClaimRequest)) as SlotClaimRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotClaimRequest() / SlotClaimRequest.new instead')
  static SlotClaimRequest create() => SlotClaimRequest._();
  static $pb.GeneratedMessage $_createMessage() => SlotClaimRequest._();
  @$core.override
  SlotClaimRequest createEmptyInstance() => SlotClaimRequest._();
  @$core.pragma('dart2js:noInline')
  static SlotClaimRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimRequest>(SlotClaimRequest.$_createMessage);
  static SlotClaimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get periodIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set periodIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriodIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get slotIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set slotIndex($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlotIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlotIndex() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get question => $_getSZ(3);
  @$pb.TagNumber(4)
  set question($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuestion() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuestion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isStandard => $_getBF(4);
  @$pb.TagNumber(5)
  set isStandard($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsStandard() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsStandard() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isScaled => $_getBF(5);
  @$pb.TagNumber(6)
  set isScaled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsScaled() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsScaled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get min => $_getIZ(6);
  @$pb.TagNumber(7)
  set min($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMin() => $_has(6);
  @$pb.TagNumber(7)
  void clearMin() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get max => $_getIZ(7);
  @$pb.TagNumber(8)
  set max($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMax() => $_has(7);
  @$pb.TagNumber(8)
  void clearMax() => $_clearField(8);
}

class SlotClaimResponse extends $pb.GeneratedMessage {
  factory SlotClaimResponse({
    $core.String? txid,
  }) {
    final result = SlotClaimResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SlotClaimResponse._();

  factory SlotClaimResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimResponse()..mergeFromBuffer(data, registry);
  factory SlotClaimResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotClaimResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimResponse copyWith(void Function(SlotClaimResponse) updates) =>
      super.copyWith((message) => updates(message as SlotClaimResponse)) as SlotClaimResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotClaimResponse() / SlotClaimResponse.new instead')
  static SlotClaimResponse create() => SlotClaimResponse._();
  static $pb.GeneratedMessage $_createMessage() => SlotClaimResponse._();
  @$core.override
  SlotClaimResponse createEmptyInstance() => SlotClaimResponse._();
  @$core.pragma('dart2js:noInline')
  static SlotClaimResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SlotClaimResponse>(SlotClaimResponse.$_createMessage);
  static SlotClaimResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class SlotClaimCategoryRequest extends $pb.GeneratedMessage {
  factory SlotClaimCategoryRequest({
    $core.String? slotsJson,
    $core.bool? isStandard,
    $fixnum.Int64? feeSats,
  }) {
    final result = SlotClaimCategoryRequest._();
    if (slotsJson != null) result.slotsJson = slotsJson;
    if (isStandard != null) result.isStandard = isStandard;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  SlotClaimCategoryRequest._();

  factory SlotClaimCategoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimCategoryRequest()..mergeFromBuffer(data, registry);
  factory SlotClaimCategoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimCategoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimCategoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotClaimCategoryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'slotsJson')
    ..aOB(2, _omitFieldNames ? '' : 'isStandard')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimCategoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimCategoryRequest copyWith(void Function(SlotClaimCategoryRequest) updates) =>
      super.copyWith((message) => updates(message as SlotClaimCategoryRequest)) as SlotClaimCategoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotClaimCategoryRequest() / SlotClaimCategoryRequest.new instead')
  static SlotClaimCategoryRequest create() => SlotClaimCategoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => SlotClaimCategoryRequest._();
  @$core.override
  SlotClaimCategoryRequest createEmptyInstance() => SlotClaimCategoryRequest._();
  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SlotClaimCategoryRequest>(SlotClaimCategoryRequest.$_createMessage);
  static SlotClaimCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlotsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotsJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isStandard => $_getBF(1);
  @$pb.TagNumber(2)
  set isStandard($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsStandard() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsStandard() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);
}

class SlotClaimCategoryResponse extends $pb.GeneratedMessage {
  factory SlotClaimCategoryResponse({
    $core.String? txid,
  }) {
    final result = SlotClaimCategoryResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SlotClaimCategoryResponse._();

  factory SlotClaimCategoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimCategoryResponse()..mergeFromBuffer(data, registry);
  factory SlotClaimCategoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SlotClaimCategoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SlotClaimCategoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: SlotClaimCategoryResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimCategoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotClaimCategoryResponse copyWith(void Function(SlotClaimCategoryResponse) updates) =>
      super.copyWith((message) => updates(message as SlotClaimCategoryResponse)) as SlotClaimCategoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SlotClaimCategoryResponse() / SlotClaimCategoryResponse.new instead')
  static SlotClaimCategoryResponse create() => SlotClaimCategoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => SlotClaimCategoryResponse._();
  @$core.override
  SlotClaimCategoryResponse createEmptyInstance() => SlotClaimCategoryResponse._();
  @$core.pragma('dart2js:noInline')
  static SlotClaimCategoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SlotClaimCategoryResponse>(SlotClaimCategoryResponse.$_createMessage);
  static SlotClaimCategoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetVoterAddressRequest extends $pb.GeneratedMessage {
  factory GetVoterAddressRequest() => GetVoterAddressRequest._();

  GetVoterAddressRequest._();

  factory GetVoterAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVoterAddressRequest()..mergeFromBuffer(data, registry);
  factory GetVoterAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVoterAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVoterAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetVoterAddressRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVoterAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVoterAddressRequest copyWith(void Function(GetVoterAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetVoterAddressRequest)) as GetVoterAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetVoterAddressRequest() / GetVoterAddressRequest.new instead')
  static GetVoterAddressRequest create() => GetVoterAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetVoterAddressRequest._();
  @$core.override
  GetVoterAddressRequest createEmptyInstance() => GetVoterAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetVoterAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVoterAddressRequest>(GetVoterAddressRequest.$_createMessage);
  static GetVoterAddressRequest? _defaultInstance;
}

class GetVoterAddressResponse extends $pb.GeneratedMessage {
  factory GetVoterAddressResponse({
    $core.String? address,
  }) {
    final result = GetVoterAddressResponse._();
    if (address != null) result.address = address;
    return result;
  }

  GetVoterAddressResponse._();

  factory GetVoterAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVoterAddressResponse()..mergeFromBuffer(data, registry);
  factory GetVoterAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVoterAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVoterAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: GetVoterAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVoterAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVoterAddressResponse copyWith(void Function(GetVoterAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetVoterAddressResponse)) as GetVoterAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetVoterAddressResponse() / GetVoterAddressResponse.new instead')
  static GetVoterAddressResponse create() => GetVoterAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetVoterAddressResponse._();
  @$core.override
  GetVoterAddressResponse createEmptyInstance() => GetVoterAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetVoterAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVoterAddressResponse>(GetVoterAddressResponse.$_createMessage);
  static GetVoterAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class VoteVoterRequest extends $pb.GeneratedMessage {
  factory VoteVoterRequest({
    $core.String? address,
  }) {
    final result = VoteVoterRequest._();
    if (address != null) result.address = address;
    return result;
  }

  VoteVoterRequest._();

  factory VoteVoterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVoterRequest()..mergeFromBuffer(data, registry);
  factory VoteVoterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVoterRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVoterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteVoterRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVoterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVoterRequest copyWith(void Function(VoteVoterRequest) updates) =>
      super.copyWith((message) => updates(message as VoteVoterRequest)) as VoteVoterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteVoterRequest() / VoteVoterRequest.new instead')
  static VoteVoterRequest create() => VoteVoterRequest._();
  static $pb.GeneratedMessage $_createMessage() => VoteVoterRequest._();
  @$core.override
  VoteVoterRequest createEmptyInstance() => VoteVoterRequest._();
  @$core.pragma('dart2js:noInline')
  static VoteVoterRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVoterRequest>(VoteVoterRequest.$_createMessage);
  static VoteVoterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class VoteVoterResponse extends $pb.GeneratedMessage {
  factory VoteVoterResponse({
    $core.String? voterJson,
  }) {
    final result = VoteVoterResponse._();
    if (voterJson != null) result.voterJson = voterJson;
    return result;
  }

  VoteVoterResponse._();

  factory VoteVoterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVoterResponse()..mergeFromBuffer(data, registry);
  factory VoteVoterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVoterResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVoterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteVoterResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'voterJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVoterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVoterResponse copyWith(void Function(VoteVoterResponse) updates) =>
      super.copyWith((message) => updates(message as VoteVoterResponse)) as VoteVoterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteVoterResponse() / VoteVoterResponse.new instead')
  static VoteVoterResponse create() => VoteVoterResponse._();
  static $pb.GeneratedMessage $_createMessage() => VoteVoterResponse._();
  @$core.override
  VoteVoterResponse createEmptyInstance() => VoteVoterResponse._();
  @$core.pragma('dart2js:noInline')
  static VoteVoterResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVoterResponse>(VoteVoterResponse.$_createMessage);
  static VoteVoterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get voterJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set voterJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoterJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoterJson() => $_clearField(1);
}

class VoteVotersRequest extends $pb.GeneratedMessage {
  factory VoteVotersRequest() => VoteVotersRequest._();

  VoteVotersRequest._();

  factory VoteVotersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVotersRequest()..mergeFromBuffer(data, registry);
  factory VoteVotersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVotersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVotersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteVotersRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVotersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVotersRequest copyWith(void Function(VoteVotersRequest) updates) =>
      super.copyWith((message) => updates(message as VoteVotersRequest)) as VoteVotersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteVotersRequest() / VoteVotersRequest.new instead')
  static VoteVotersRequest create() => VoteVotersRequest._();
  static $pb.GeneratedMessage $_createMessage() => VoteVotersRequest._();
  @$core.override
  VoteVotersRequest createEmptyInstance() => VoteVotersRequest._();
  @$core.pragma('dart2js:noInline')
  static VoteVotersRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVotersRequest>(VoteVotersRequest.$_createMessage);
  static VoteVotersRequest? _defaultInstance;
}

class VoteVotersResponse extends $pb.GeneratedMessage {
  factory VoteVotersResponse({
    $core.String? votersJson,
  }) {
    final result = VoteVotersResponse._();
    if (votersJson != null) result.votersJson = votersJson;
    return result;
  }

  VoteVotersResponse._();

  factory VoteVotersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVotersResponse()..mergeFromBuffer(data, registry);
  factory VoteVotersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteVotersResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteVotersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteVotersResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'votersJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVotersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteVotersResponse copyWith(void Function(VoteVotersResponse) updates) =>
      super.copyWith((message) => updates(message as VoteVotersResponse)) as VoteVotersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteVotersResponse() / VoteVotersResponse.new instead')
  static VoteVotersResponse create() => VoteVotersResponse._();
  static $pb.GeneratedMessage $_createMessage() => VoteVotersResponse._();
  @$core.override
  VoteVotersResponse createEmptyInstance() => VoteVotersResponse._();
  @$core.pragma('dart2js:noInline')
  static VoteVotersResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteVotersResponse>(VoteVotersResponse.$_createMessage);
  static VoteVotersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votersJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votersJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVotersJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotersJson() => $_clearField(1);
}

class VoteSubmitRequest extends $pb.GeneratedMessage {
  factory VoteSubmitRequest({
    $core.String? votesJson,
    $fixnum.Int64? feeSats,
  }) {
    final result = VoteSubmitRequest._();
    if (votesJson != null) result.votesJson = votesJson;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  VoteSubmitRequest._();

  factory VoteSubmitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteSubmitRequest()..mergeFromBuffer(data, registry);
  factory VoteSubmitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteSubmitRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteSubmitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteSubmitRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'votesJson')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteSubmitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteSubmitRequest copyWith(void Function(VoteSubmitRequest) updates) =>
      super.copyWith((message) => updates(message as VoteSubmitRequest)) as VoteSubmitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteSubmitRequest() / VoteSubmitRequest.new instead')
  static VoteSubmitRequest create() => VoteSubmitRequest._();
  static $pb.GeneratedMessage $_createMessage() => VoteSubmitRequest._();
  @$core.override
  VoteSubmitRequest createEmptyInstance() => VoteSubmitRequest._();
  @$core.pragma('dart2js:noInline')
  static VoteSubmitRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteSubmitRequest>(VoteSubmitRequest.$_createMessage);
  static VoteSubmitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votesJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votesJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVotesJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotesJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);
}

class VoteSubmitResponse extends $pb.GeneratedMessage {
  factory VoteSubmitResponse({
    $core.String? txid,
  }) {
    final result = VoteSubmitResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  VoteSubmitResponse._();

  factory VoteSubmitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteSubmitResponse()..mergeFromBuffer(data, registry);
  factory VoteSubmitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteSubmitResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteSubmitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteSubmitResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteSubmitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteSubmitResponse copyWith(void Function(VoteSubmitResponse) updates) =>
      super.copyWith((message) => updates(message as VoteSubmitResponse)) as VoteSubmitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteSubmitResponse() / VoteSubmitResponse.new instead')
  static VoteSubmitResponse create() => VoteSubmitResponse._();
  static $pb.GeneratedMessage $_createMessage() => VoteSubmitResponse._();
  @$core.override
  VoteSubmitResponse createEmptyInstance() => VoteSubmitResponse._();
  @$core.pragma('dart2js:noInline')
  static VoteSubmitResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteSubmitResponse>(VoteSubmitResponse.$_createMessage);
  static VoteSubmitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class VoteListRequest extends $pb.GeneratedMessage {
  factory VoteListRequest({
    $core.String? voter,
    $core.String? decisionId,
    $core.int? periodId,
  }) {
    final result = VoteListRequest._();
    if (voter != null) result.voter = voter;
    if (decisionId != null) result.decisionId = decisionId;
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  VoteListRequest._();

  factory VoteListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteListRequest()..mergeFromBuffer(data, registry);
  factory VoteListRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'voter')
    ..aOS(2, _omitFieldNames ? '' : 'decisionId')
    ..aI(3, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteListRequest copyWith(void Function(VoteListRequest) updates) =>
      super.copyWith((message) => updates(message as VoteListRequest)) as VoteListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteListRequest() / VoteListRequest.new instead')
  static VoteListRequest create() => VoteListRequest._();
  static $pb.GeneratedMessage $_createMessage() => VoteListRequest._();
  @$core.override
  VoteListRequest createEmptyInstance() => VoteListRequest._();
  @$core.pragma('dart2js:noInline')
  static VoteListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteListRequest>(VoteListRequest.$_createMessage);
  static VoteListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get voter => $_getSZ(0);
  @$pb.TagNumber(1)
  set voter($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoter() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoter() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get decisionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set decisionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDecisionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecisionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get periodId => $_getIZ(2);
  @$pb.TagNumber(3)
  set periodId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPeriodId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPeriodId() => $_clearField(3);
}

class VoteListResponse extends $pb.GeneratedMessage {
  factory VoteListResponse({
    $core.String? votesJson,
  }) {
    final result = VoteListResponse._();
    if (votesJson != null) result.votesJson = votesJson;
    return result;
  }

  VoteListResponse._();

  factory VoteListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteListResponse()..mergeFromBuffer(data, registry);
  factory VoteListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoteListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VoteListResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'votesJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteListResponse copyWith(void Function(VoteListResponse) updates) =>
      super.copyWith((message) => updates(message as VoteListResponse)) as VoteListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VoteListResponse() / VoteListResponse.new instead')
  static VoteListResponse create() => VoteListResponse._();
  static $pb.GeneratedMessage $_createMessage() => VoteListResponse._();
  @$core.override
  VoteListResponse createEmptyInstance() => VoteListResponse._();
  @$core.pragma('dart2js:noInline')
  static VoteListResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteListResponse>(VoteListResponse.$_createMessage);
  static VoteListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get votesJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set votesJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVotesJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearVotesJson() => $_clearField(1);
}

class VotePeriodRequest extends $pb.GeneratedMessage {
  factory VotePeriodRequest({
    $core.int? periodId,
  }) {
    final result = VotePeriodRequest._();
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  VotePeriodRequest._();

  factory VotePeriodRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotePeriodRequest()..mergeFromBuffer(data, registry);
  factory VotePeriodRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotePeriodRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotePeriodRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotePeriodRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotePeriodRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotePeriodRequest copyWith(void Function(VotePeriodRequest) updates) =>
      super.copyWith((message) => updates(message as VotePeriodRequest)) as VotePeriodRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotePeriodRequest() / VotePeriodRequest.new instead')
  static VotePeriodRequest create() => VotePeriodRequest._();
  static $pb.GeneratedMessage $_createMessage() => VotePeriodRequest._();
  @$core.override
  VotePeriodRequest createEmptyInstance() => VotePeriodRequest._();
  @$core.pragma('dart2js:noInline')
  static VotePeriodRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotePeriodRequest>(VotePeriodRequest.$_createMessage);
  static VotePeriodRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get periodId => $_getIZ(0);
  @$pb.TagNumber(1)
  set periodId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeriodId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriodId() => $_clearField(1);
}

class VotePeriodResponse extends $pb.GeneratedMessage {
  factory VotePeriodResponse({
    $core.String? periodJson,
  }) {
    final result = VotePeriodResponse._();
    if (periodJson != null) result.periodJson = periodJson;
    return result;
  }

  VotePeriodResponse._();

  factory VotePeriodResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotePeriodResponse()..mergeFromBuffer(data, registry);
  factory VotePeriodResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotePeriodResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotePeriodResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotePeriodResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'periodJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotePeriodResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotePeriodResponse copyWith(void Function(VotePeriodResponse) updates) =>
      super.copyWith((message) => updates(message as VotePeriodResponse)) as VotePeriodResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotePeriodResponse() / VotePeriodResponse.new instead')
  static VotePeriodResponse create() => VotePeriodResponse._();
  static $pb.GeneratedMessage $_createMessage() => VotePeriodResponse._();
  @$core.override
  VotePeriodResponse createEmptyInstance() => VotePeriodResponse._();
  @$core.pragma('dart2js:noInline')
  static VotePeriodResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VotePeriodResponse>(VotePeriodResponse.$_createMessage);
  static VotePeriodResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get periodJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set periodJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeriodJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriodJson() => $_clearField(1);
}

class VotecoinTransferRequest extends $pb.GeneratedMessage {
  factory VotecoinTransferRequest({
    $core.String? dest,
    @$core.Deprecated('This field is deprecated.') $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
    $core.String? memo,
    $core.double? votecoinAmount,
  }) {
    final result = VotecoinTransferRequest._();
    if (dest != null) result.dest = dest;
    if (amount != null) result.amount = amount;
    if (feeSats != null) result.feeSats = feeSats;
    if (memo != null) result.memo = memo;
    if (votecoinAmount != null) result.votecoinAmount = votecoinAmount;
    return result;
  }

  VotecoinTransferRequest._();

  factory VotecoinTransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinTransferRequest()..mergeFromBuffer(data, registry);
  factory VotecoinTransferRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinTransferRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinTransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotecoinTransferRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dest')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
    ..aD(5, _omitFieldNames ? '' : 'votecoinAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinTransferRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinTransferRequest copyWith(void Function(VotecoinTransferRequest) updates) =>
      super.copyWith((message) => updates(message as VotecoinTransferRequest)) as VotecoinTransferRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotecoinTransferRequest() / VotecoinTransferRequest.new instead')
  static VotecoinTransferRequest create() => VotecoinTransferRequest._();
  static $pb.GeneratedMessage $_createMessage() => VotecoinTransferRequest._();
  @$core.override
  VotecoinTransferRequest createEmptyInstance() => VotecoinTransferRequest._();
  @$core.pragma('dart2js:noInline')
  static VotecoinTransferRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VotecoinTransferRequest>(VotecoinTransferRequest.$_createMessage);
  static VotecoinTransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dest => $_getSZ(0);
  @$pb.TagNumber(1)
  set dest($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDest() => $_clearField(1);

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 value) => $_setInt64(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

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

  @$pb.TagNumber(5)
  $core.double get votecoinAmount => $_getN(4);
  @$pb.TagNumber(5)
  set votecoinAmount($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVotecoinAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearVotecoinAmount() => $_clearField(5);
}

class VotecoinTransferResponse extends $pb.GeneratedMessage {
  factory VotecoinTransferResponse({
    $core.String? txid,
  }) {
    final result = VotecoinTransferResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  VotecoinTransferResponse._();

  factory VotecoinTransferResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinTransferResponse()..mergeFromBuffer(data, registry);
  factory VotecoinTransferResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinTransferResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinTransferResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotecoinTransferResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinTransferResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinTransferResponse copyWith(void Function(VotecoinTransferResponse) updates) =>
      super.copyWith((message) => updates(message as VotecoinTransferResponse)) as VotecoinTransferResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotecoinTransferResponse() / VotecoinTransferResponse.new instead')
  static VotecoinTransferResponse create() => VotecoinTransferResponse._();
  static $pb.GeneratedMessage $_createMessage() => VotecoinTransferResponse._();
  @$core.override
  VotecoinTransferResponse createEmptyInstance() => VotecoinTransferResponse._();
  @$core.pragma('dart2js:noInline')
  static VotecoinTransferResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VotecoinTransferResponse>(VotecoinTransferResponse.$_createMessage);
  static VotecoinTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class VotecoinBalanceRequest extends $pb.GeneratedMessage {
  factory VotecoinBalanceRequest({
    $core.String? address,
  }) {
    final result = VotecoinBalanceRequest._();
    if (address != null) result.address = address;
    return result;
  }

  VotecoinBalanceRequest._();

  factory VotecoinBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinBalanceRequest()..mergeFromBuffer(data, registry);
  factory VotecoinBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotecoinBalanceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinBalanceRequest copyWith(void Function(VotecoinBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as VotecoinBalanceRequest)) as VotecoinBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotecoinBalanceRequest() / VotecoinBalanceRequest.new instead')
  static VotecoinBalanceRequest create() => VotecoinBalanceRequest._();
  static $pb.GeneratedMessage $_createMessage() => VotecoinBalanceRequest._();
  @$core.override
  VotecoinBalanceRequest createEmptyInstance() => VotecoinBalanceRequest._();
  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VotecoinBalanceRequest>(VotecoinBalanceRequest.$_createMessage);
  static VotecoinBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class VotecoinBalanceResponse extends $pb.GeneratedMessage {
  factory VotecoinBalanceResponse({
    @$core.Deprecated('This field is deprecated.') $fixnum.Int64? balance,
    $core.double? votecoinBalance,
  }) {
    final result = VotecoinBalanceResponse._();
    if (balance != null) result.balance = balance;
    if (votecoinBalance != null) result.votecoinBalance = votecoinBalance;
    return result;
  }

  VotecoinBalanceResponse._();

  factory VotecoinBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinBalanceResponse()..mergeFromBuffer(data, registry);
  factory VotecoinBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VotecoinBalanceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VotecoinBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VotecoinBalanceResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'balance')
    ..aD(2, _omitFieldNames ? '' : 'votecoinBalance')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VotecoinBalanceResponse copyWith(void Function(VotecoinBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as VotecoinBalanceResponse)) as VotecoinBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VotecoinBalanceResponse() / VotecoinBalanceResponse.new instead')
  static VotecoinBalanceResponse create() => VotecoinBalanceResponse._();
  static $pb.GeneratedMessage $_createMessage() => VotecoinBalanceResponse._();
  @$core.override
  VotecoinBalanceResponse createEmptyInstance() => VotecoinBalanceResponse._();
  @$core.pragma('dart2js:noInline')
  static VotecoinBalanceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VotecoinBalanceResponse>(VotecoinBalanceResponse.$_createMessage);
  static VotecoinBalanceResponse? _defaultInstance;

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $fixnum.Int64 get balance => $_getI64(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  set balance($fixnum.Int64 value) => $_setInt64(0, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool hasBalance() => $_has(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  void clearBalance() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get votecoinBalance => $_getN(1);
  @$pb.TagNumber(2)
  set votecoinBalance($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVotecoinBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearVotecoinBalance() => $_clearField(2);
}

class TransferVotecoinRequest extends $pb.GeneratedMessage {
  factory TransferVotecoinRequest({
    $core.String? dest,
    @$core.Deprecated('This field is deprecated.') $fixnum.Int64? amount,
    $fixnum.Int64? feeSats,
    $core.String? memo,
    $core.double? votecoinAmount,
  }) {
    final result = TransferVotecoinRequest._();
    if (dest != null) result.dest = dest;
    if (amount != null) result.amount = amount;
    if (feeSats != null) result.feeSats = feeSats;
    if (memo != null) result.memo = memo;
    if (votecoinAmount != null) result.votecoinAmount = votecoinAmount;
    return result;
  }

  TransferVotecoinRequest._();

  factory TransferVotecoinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferVotecoinRequest()..mergeFromBuffer(data, registry);
  factory TransferVotecoinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferVotecoinRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferVotecoinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: TransferVotecoinRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dest')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aOS(4, _omitFieldNames ? '' : 'memo')
    ..aD(5, _omitFieldNames ? '' : 'votecoinAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferVotecoinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferVotecoinRequest copyWith(void Function(TransferVotecoinRequest) updates) =>
      super.copyWith((message) => updates(message as TransferVotecoinRequest)) as TransferVotecoinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferVotecoinRequest() / TransferVotecoinRequest.new instead')
  static TransferVotecoinRequest create() => TransferVotecoinRequest._();
  static $pb.GeneratedMessage $_createMessage() => TransferVotecoinRequest._();
  @$core.override
  TransferVotecoinRequest createEmptyInstance() => TransferVotecoinRequest._();
  @$core.pragma('dart2js:noInline')
  static TransferVotecoinRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferVotecoinRequest>(TransferVotecoinRequest.$_createMessage);
  static TransferVotecoinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dest => $_getSZ(0);
  @$pb.TagNumber(1)
  set dest($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDest() => $_clearField(1);

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 value) => $_setInt64(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

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

  @$pb.TagNumber(5)
  $core.double get votecoinAmount => $_getN(4);
  @$pb.TagNumber(5)
  set votecoinAmount($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVotecoinAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearVotecoinAmount() => $_clearField(5);
}

class TransferVotecoinResponse extends $pb.GeneratedMessage {
  factory TransferVotecoinResponse({
    $core.String? txid,
  }) {
    final result = TransferVotecoinResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  TransferVotecoinResponse._();

  factory TransferVotecoinResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferVotecoinResponse()..mergeFromBuffer(data, registry);
  factory TransferVotecoinResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransferVotecoinResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferVotecoinResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: TransferVotecoinResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferVotecoinResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferVotecoinResponse copyWith(void Function(TransferVotecoinResponse) updates) =>
      super.copyWith((message) => updates(message as TransferVotecoinResponse)) as TransferVotecoinResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransferVotecoinResponse() / TransferVotecoinResponse.new instead')
  static TransferVotecoinResponse create() => TransferVotecoinResponse._();
  static $pb.GeneratedMessage $_createMessage() => TransferVotecoinResponse._();
  @$core.override
  TransferVotecoinResponse createEmptyInstance() => TransferVotecoinResponse._();
  @$core.pragma('dart2js:noInline')
  static TransferVotecoinResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferVotecoinResponse>(TransferVotecoinResponse.$_createMessage);
  static TransferVotecoinResponse? _defaultInstance;

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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
    $core.String? dst,
  }) {
    final result = VerifySignatureRequest._();
    if (msg != null) result.msg = msg;
    if (signature != null) result.signature = signature;
    if (verifyingKey != null) result.verifyingKey = verifyingKey;
    if (dst != null) result.dst = dst;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
      createEmptyInstance: VerifySignatureRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..aOS(3, _omitFieldNames ? '' : 'verifyingKey')
    ..aOS(4, _omitFieldNames ? '' : 'dst')
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

  @$pb.TagNumber(4)
  $core.String get dst => $_getSZ(3);
  @$pb.TagNumber(4)
  set dst($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDst() => $_has(3);
  @$pb.TagNumber(4)
  void clearDst() => $_clearField(4);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'truthcoin.v1'),
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

class TruthcoinServiceApi {
  final $pb.RpcClient _client;

  TruthcoinServiceApi(this._client);

  /// Get wallet balance (total and available).
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'TruthcoinService', 'GetBalance', request, GetBalanceResponse());

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'TruthcoinService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Stop the truthcoin node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'TruthcoinService', 'Stop', request, StopResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'TruthcoinService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Withdraw to mainchain.
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
      _client.invoke<WithdrawResponse>(ctx, 'TruthcoinService', 'Withdraw', request, WithdrawResponse());

  /// Transfer within sidechain.
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
      _client.invoke<TransferResponse>(ctx, 'TruthcoinService', 'Transfer', request, TransferResponse());

  /// Get total sidechain wealth in sats.
  $async.Future<GetSidechainWealthResponse> getSidechainWealth(
          $pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
      _client.invoke<GetSidechainWealthResponse>(
          ctx, 'TruthcoinService', 'GetSidechainWealth', request, GetSidechainWealthResponse());

  /// Create a deposit transaction.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
      _client.invoke<CreateDepositResponse>(ctx, 'TruthcoinService', 'CreateDeposit', request, CreateDepositResponse());

  /// Get pending withdrawal bundle.
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
          $pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
      _client.invoke<GetPendingWithdrawalBundleResponse>(
          ctx, 'TruthcoinService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse());

  /// Connect to a peer.
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
      _client.invoke<ConnectPeerResponse>(ctx, 'TruthcoinService', 'ConnectPeer', request, ConnectPeerResponse());

  /// List connected peers.
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
      _client.invoke<ListPeersResponse>(ctx, 'TruthcoinService', 'ListPeers', request, ListPeersResponse());

  /// Mine a block.
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
      _client.invoke<MineResponse>(ctx, 'TruthcoinService', 'Mine', request, MineResponse());

  /// Get block by hash.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'TruthcoinService', 'GetBlock', request, GetBlockResponse());

  /// Get best mainchain block hash.
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
          $pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
      _client.invoke<GetBestMainchainBlockHashResponse>(
          ctx, 'TruthcoinService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse());

  /// Get best sidechain block hash.
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
          $pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
      _client.invoke<GetBestSidechainBlockHashResponse>(
          ctx, 'TruthcoinService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse());

  /// Get BMM inclusions for a block.
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
      _client.invoke<GetBmmInclusionsResponse>(
          ctx, 'TruthcoinService', 'GetBmmInclusions', request, GetBmmInclusionsResponse());

  /// Get wallet UTXOs.
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) => _client
      .invoke<GetWalletUtxosResponse>(ctx, 'TruthcoinService', 'GetWalletUtxos', request, GetWalletUtxosResponse());

  /// List all UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'TruthcoinService', 'ListUtxos', request, ListUtxosResponse());

  /// Remove transaction from mempool.
  $async.Future<RemoveFromMempoolResponse> removeFromMempool(
          $pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
      _client.invoke<RemoveFromMempoolResponse>(
          ctx, 'TruthcoinService', 'RemoveFromMempool', request, RemoveFromMempoolResponse());

  /// Get latest failed withdrawal bundle height.
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
          $pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
      _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'TruthcoinService',
          'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse());

  /// Generate a new mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'TruthcoinService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// Set seed from mnemonic.
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic(
          $pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
      _client.invoke<SetSeedFromMnemonicResponse>(
          ctx, 'TruthcoinService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse());

  /// Raw JSON-RPC passthrough for debug console.
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
      _client.invoke<CallRawResponse>(ctx, 'TruthcoinService', 'CallRaw', request, CallRawResponse());

  /// Refresh wallet state.
  $async.Future<RefreshWalletResponse> refreshWallet($pb.ClientContext? ctx, RefreshWalletRequest request) =>
      _client.invoke<RefreshWalletResponse>(ctx, 'TruthcoinService', 'RefreshWallet', request, RefreshWalletResponse());

  /// Get transaction by txid.
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) => _client
      .invoke<GetTransactionResponse>(ctx, 'TruthcoinService', 'GetTransaction', request, GetTransactionResponse());

  /// Get transaction info.
  $async.Future<GetTransactionInfoResponse> getTransactionInfo(
          $pb.ClientContext? ctx, GetTransactionInfoRequest request) =>
      _client.invoke<GetTransactionInfoResponse>(
          ctx, 'TruthcoinService', 'GetTransactionInfo', request, GetTransactionInfoResponse());

  /// Get wallet addresses.
  $async.Future<GetWalletAddressesResponse> getWalletAddresses(
          $pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
      _client.invoke<GetWalletAddressesResponse>(
          ctx, 'TruthcoinService', 'GetWalletAddresses', request, GetWalletAddressesResponse());

  /// Get owned UTXOs (confirmed).
  $async.Future<MyUtxosResponse> myUtxos($pb.ClientContext? ctx, MyUtxosRequest request) =>
      _client.invoke<MyUtxosResponse>(ctx, 'TruthcoinService', 'MyUtxos', request, MyUtxosResponse());

  /// Get owned UTXOs (unconfirmed).
  $async.Future<MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
          $pb.ClientContext? ctx, MyUnconfirmedUtxosRequest request) =>
      _client.invoke<MyUnconfirmedUtxosResponse>(
          ctx, 'TruthcoinService', 'MyUnconfirmedUtxos', request, MyUnconfirmedUtxosResponse());

  /// Calculate initial liquidity required for market creation.
  $async.Future<CalculateInitialLiquidityResponse> calculateInitialLiquidity(
          $pb.ClientContext? ctx, CalculateInitialLiquidityRequest request) =>
      _client.invoke<CalculateInitialLiquidityResponse>(
          ctx, 'TruthcoinService', 'CalculateInitialLiquidity', request, CalculateInitialLiquidityResponse());

  /// Create a new prediction market.
  $async.Future<MarketCreateResponse> marketCreate($pb.ClientContext? ctx, MarketCreateRequest request) =>
      _client.invoke<MarketCreateResponse>(ctx, 'TruthcoinService', 'MarketCreate', request, MarketCreateResponse());

  /// List all markets.
  $async.Future<MarketListResponse> marketList($pb.ClientContext? ctx, MarketListRequest request) =>
      _client.invoke<MarketListResponse>(ctx, 'TruthcoinService', 'MarketList', request, MarketListResponse());

  /// Get a specific market.
  $async.Future<MarketGetResponse> marketGet($pb.ClientContext? ctx, MarketGetRequest request) =>
      _client.invoke<MarketGetResponse>(ctx, 'TruthcoinService', 'MarketGet', request, MarketGetResponse());

  /// Buy shares in a market.
  $async.Future<MarketBuyResponse> marketBuy($pb.ClientContext? ctx, MarketBuyRequest request) =>
      _client.invoke<MarketBuyResponse>(ctx, 'TruthcoinService', 'MarketBuy', request, MarketBuyResponse());

  /// Sell shares in a market.
  $async.Future<MarketSellResponse> marketSell($pb.ClientContext? ctx, MarketSellRequest request) =>
      _client.invoke<MarketSellResponse>(ctx, 'TruthcoinService', 'MarketSell', request, MarketSellResponse());

  /// Get positions in a market.
  $async.Future<MarketPositionsResponse> marketPositions($pb.ClientContext? ctx, MarketPositionsRequest request) =>
      _client.invoke<MarketPositionsResponse>(
          ctx, 'TruthcoinService', 'MarketPositions', request, MarketPositionsResponse());

  /// Add liquidity to a market that a wallet address created.
  $async.Future<MarketAmplifyBetaResponse> marketAmplifyBeta(
          $pb.ClientContext? ctx, MarketAmplifyBetaRequest request) =>
      _client.invoke<MarketAmplifyBetaResponse>(
          ctx, 'TruthcoinService', 'MarketAmplifyBeta', request, MarketAmplifyBetaResponse());

  /// Get slot system status and configuration.
  $async.Future<SlotStatusResponse> slotStatus($pb.ClientContext? ctx, SlotStatusRequest request) =>
      _client.invoke<SlotStatusResponse>(ctx, 'TruthcoinService', 'SlotStatus', request, SlotStatusResponse());

  /// List slots with optional filtering.
  $async.Future<SlotListResponse> slotList($pb.ClientContext? ctx, SlotListRequest request) =>
      _client.invoke<SlotListResponse>(ctx, 'TruthcoinService', 'SlotList', request, SlotListResponse());

  /// Get a specific slot by ID.
  $async.Future<SlotGetResponse> slotGet($pb.ClientContext? ctx, SlotGetRequest request) =>
      _client.invoke<SlotGetResponse>(ctx, 'TruthcoinService', 'SlotGet', request, SlotGetResponse());

  /// Claim a decision slot.
  $async.Future<SlotClaimResponse> slotClaim($pb.ClientContext? ctx, SlotClaimRequest request) =>
      _client.invoke<SlotClaimResponse>(ctx, 'TruthcoinService', 'SlotClaim', request, SlotClaimResponse());

  /// Claim multiple slots as a category.
  $async.Future<SlotClaimCategoryResponse> slotClaimCategory(
          $pb.ClientContext? ctx, SlotClaimCategoryRequest request) =>
      _client.invoke<SlotClaimCategoryResponse>(
          ctx, 'TruthcoinService', 'SlotClaimCategory', request, SlotClaimCategoryResponse());

  /// Get the voter address of the wallet.
  $async.Future<GetVoterAddressResponse> getVoterAddress($pb.ClientContext? ctx, GetVoterAddressRequest request) =>
      _client.invoke<GetVoterAddressResponse>(
          ctx, 'TruthcoinService', 'GetVoterAddress', request, GetVoterAddressResponse());

  /// Get voter info.
  $async.Future<VoteVoterResponse> voteVoter($pb.ClientContext? ctx, VoteVoterRequest request) =>
      _client.invoke<VoteVoterResponse>(ctx, 'TruthcoinService', 'VoteVoter', request, VoteVoterResponse());

  /// List all voters.
  $async.Future<VoteVotersResponse> voteVoters($pb.ClientContext? ctx, VoteVotersRequest request) =>
      _client.invoke<VoteVotersResponse>(ctx, 'TruthcoinService', 'VoteVoters', request, VoteVotersResponse());

  /// Submit votes (batch).
  $async.Future<VoteSubmitResponse> voteSubmit($pb.ClientContext? ctx, VoteSubmitRequest request) =>
      _client.invoke<VoteSubmitResponse>(ctx, 'TruthcoinService', 'VoteSubmit', request, VoteSubmitResponse());

  /// List votes with optional filters.
  $async.Future<VoteListResponse> voteList($pb.ClientContext? ctx, VoteListRequest request) =>
      _client.invoke<VoteListResponse>(ctx, 'TruthcoinService', 'VoteList', request, VoteListResponse());

  /// Get voting period information.
  $async.Future<VotePeriodResponse> votePeriod($pb.ClientContext? ctx, VotePeriodRequest request) =>
      _client.invoke<VotePeriodResponse>(ctx, 'TruthcoinService', 'VotePeriod', request, VotePeriodResponse());

  /// Transfer votecoins.
  $async.Future<VotecoinTransferResponse> votecoinTransfer($pb.ClientContext? ctx, VotecoinTransferRequest request) =>
      _client.invoke<VotecoinTransferResponse>(
          ctx, 'TruthcoinService', 'VotecoinTransfer', request, VotecoinTransferResponse());

  /// Get votecoin balance for an address.
  $async.Future<VotecoinBalanceResponse> votecoinBalance($pb.ClientContext? ctx, VotecoinBalanceRequest request) =>
      _client.invoke<VotecoinBalanceResponse>(
          ctx, 'TruthcoinService', 'VotecoinBalance', request, VotecoinBalanceResponse());

  /// Transfer votecoin (alternative method).
  $async.Future<TransferVotecoinResponse> transferVotecoin($pb.ClientContext? ctx, TransferVotecoinRequest request) =>
      _client.invoke<TransferVotecoinResponse>(
          ctx, 'TruthcoinService', 'TransferVotecoin', request, TransferVotecoinResponse());

  /// Get a new encryption key.
  $async.Future<GetNewEncryptionKeyResponse> getNewEncryptionKey(
          $pb.ClientContext? ctx, GetNewEncryptionKeyRequest request) =>
      _client.invoke<GetNewEncryptionKeyResponse>(
          ctx, 'TruthcoinService', 'GetNewEncryptionKey', request, GetNewEncryptionKeyResponse());

  /// Get a new verifying key.
  $async.Future<GetNewVerifyingKeyResponse> getNewVerifyingKey(
          $pb.ClientContext? ctx, GetNewVerifyingKeyRequest request) =>
      _client.invoke<GetNewVerifyingKeyResponse>(
          ctx, 'TruthcoinService', 'GetNewVerifyingKey', request, GetNewVerifyingKeyResponse());

  /// Encrypt a message.
  $async.Future<EncryptMsgResponse> encryptMsg($pb.ClientContext? ctx, EncryptMsgRequest request) =>
      _client.invoke<EncryptMsgResponse>(ctx, 'TruthcoinService', 'EncryptMsg', request, EncryptMsgResponse());

  /// Decrypt a message.
  $async.Future<DecryptMsgResponse> decryptMsg($pb.ClientContext? ctx, DecryptMsgRequest request) =>
      _client.invoke<DecryptMsgResponse>(ctx, 'TruthcoinService', 'DecryptMsg', request, DecryptMsgResponse());

  /// Sign an arbitrary message with verifying key.
  $async.Future<SignArbitraryMsgResponse> signArbitraryMsg($pb.ClientContext? ctx, SignArbitraryMsgRequest request) =>
      _client.invoke<SignArbitraryMsgResponse>(
          ctx, 'TruthcoinService', 'SignArbitraryMsg', request, SignArbitraryMsgResponse());

  /// Sign an arbitrary message as address.
  $async.Future<SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
          $pb.ClientContext? ctx, SignArbitraryMsgAsAddrRequest request) =>
      _client.invoke<SignArbitraryMsgAsAddrResponse>(
          ctx, 'TruthcoinService', 'SignArbitraryMsgAsAddr', request, SignArbitraryMsgAsAddrResponse());

  /// Verify a signature.
  $async.Future<VerifySignatureResponse> verifySignature($pb.ClientContext? ctx, VerifySignatureRequest request) =>
      _client.invoke<VerifySignatureResponse>(
          ctx, 'TruthcoinService', 'VerifySignature', request, VerifySignatureResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
