// This is a generated file - do not edit.
//
// Generated from photon/v1/photon.proto.

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'photon.v1'),
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

class PhotonServiceApi {
  final $pb.RpcClient _client;

  PhotonServiceApi(this._client);

  /// Get wallet balance (total and available).
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'PhotonService', 'GetBalance', request, GetBalanceResponse());

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'PhotonService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Stop the photon node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'PhotonService', 'Stop', request, StopResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'PhotonService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Withdraw to mainchain.
  $async.Future<WithdrawResponse> withdraw($pb.ClientContext? ctx, WithdrawRequest request) =>
      _client.invoke<WithdrawResponse>(ctx, 'PhotonService', 'Withdraw', request, WithdrawResponse());

  /// Transfer within sidechain.
  $async.Future<TransferResponse> transfer($pb.ClientContext? ctx, TransferRequest request) =>
      _client.invoke<TransferResponse>(ctx, 'PhotonService', 'Transfer', request, TransferResponse());

  /// Get total sidechain wealth in sats.
  $async.Future<GetSidechainWealthResponse> getSidechainWealth(
          $pb.ClientContext? ctx, GetSidechainWealthRequest request) =>
      _client.invoke<GetSidechainWealthResponse>(
          ctx, 'PhotonService', 'GetSidechainWealth', request, GetSidechainWealthResponse());

  /// Create a deposit transaction.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) =>
      _client.invoke<CreateDepositResponse>(ctx, 'PhotonService', 'CreateDeposit', request, CreateDepositResponse());

  /// Get pending withdrawal bundle.
  $async.Future<GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
          $pb.ClientContext? ctx, GetPendingWithdrawalBundleRequest request) =>
      _client.invoke<GetPendingWithdrawalBundleResponse>(
          ctx, 'PhotonService', 'GetPendingWithdrawalBundle', request, GetPendingWithdrawalBundleResponse());

  /// Connect to a peer.
  $async.Future<ConnectPeerResponse> connectPeer($pb.ClientContext? ctx, ConnectPeerRequest request) =>
      _client.invoke<ConnectPeerResponse>(ctx, 'PhotonService', 'ConnectPeer', request, ConnectPeerResponse());

  /// Forget a peer.
  $async.Future<ForgetPeerResponse> forgetPeer($pb.ClientContext? ctx, ForgetPeerRequest request) =>
      _client.invoke<ForgetPeerResponse>(ctx, 'PhotonService', 'ForgetPeer', request, ForgetPeerResponse());

  /// List connected peers.
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, ListPeersRequest request) =>
      _client.invoke<ListPeersResponse>(ctx, 'PhotonService', 'ListPeers', request, ListPeersResponse());

  /// Mine a block.
  $async.Future<MineResponse> mine($pb.ClientContext? ctx, MineRequest request) =>
      _client.invoke<MineResponse>(ctx, 'PhotonService', 'Mine', request, MineResponse());

  /// Get block by hash.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'PhotonService', 'GetBlock', request, GetBlockResponse());

  /// Get best mainchain block hash.
  $async.Future<GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
          $pb.ClientContext? ctx, GetBestMainchainBlockHashRequest request) =>
      _client.invoke<GetBestMainchainBlockHashResponse>(
          ctx, 'PhotonService', 'GetBestMainchainBlockHash', request, GetBestMainchainBlockHashResponse());

  /// Get best sidechain block hash.
  $async.Future<GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
          $pb.ClientContext? ctx, GetBestSidechainBlockHashRequest request) =>
      _client.invoke<GetBestSidechainBlockHashResponse>(
          ctx, 'PhotonService', 'GetBestSidechainBlockHash', request, GetBestSidechainBlockHashResponse());

  /// Get BMM inclusions for a block.
  $async.Future<GetBmmInclusionsResponse> getBmmInclusions($pb.ClientContext? ctx, GetBmmInclusionsRequest request) =>
      _client.invoke<GetBmmInclusionsResponse>(
          ctx, 'PhotonService', 'GetBmmInclusions', request, GetBmmInclusionsResponse());

  /// Get wallet UTXOs.
  $async.Future<GetWalletUtxosResponse> getWalletUtxos($pb.ClientContext? ctx, GetWalletUtxosRequest request) =>
      _client.invoke<GetWalletUtxosResponse>(ctx, 'PhotonService', 'GetWalletUtxos', request, GetWalletUtxosResponse());

  /// List all UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'PhotonService', 'ListUtxos', request, ListUtxosResponse());

  /// Remove transaction from mempool.
  $async.Future<RemoveFromMempoolResponse> removeFromMempool(
          $pb.ClientContext? ctx, RemoveFromMempoolRequest request) =>
      _client.invoke<RemoveFromMempoolResponse>(
          ctx, 'PhotonService', 'RemoveFromMempool', request, RemoveFromMempoolResponse());

  /// Get latest failed withdrawal bundle height.
  $async.Future<GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
          $pb.ClientContext? ctx, GetLatestFailedWithdrawalBundleHeightRequest request) =>
      _client.invoke<GetLatestFailedWithdrawalBundleHeightResponse>(ctx, 'PhotonService',
          'GetLatestFailedWithdrawalBundleHeight', request, GetLatestFailedWithdrawalBundleHeightResponse());

  /// Generate a new mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'PhotonService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// Set seed from mnemonic.
  $async.Future<SetSeedFromMnemonicResponse> setSeedFromMnemonic(
          $pb.ClientContext? ctx, SetSeedFromMnemonicRequest request) =>
      _client.invoke<SetSeedFromMnemonicResponse>(
          ctx, 'PhotonService', 'SetSeedFromMnemonic', request, SetSeedFromMnemonicResponse());

  /// Raw JSON-RPC passthrough for debug console.
  $async.Future<CallRawResponse> callRaw($pb.ClientContext? ctx, CallRawRequest request) =>
      _client.invoke<CallRawResponse>(ctx, 'PhotonService', 'CallRaw', request, CallRawResponse());

  /// Get wallet addresses.
  $async.Future<GetWalletAddressesResponse> getWalletAddresses(
          $pb.ClientContext? ctx, GetWalletAddressesRequest request) =>
      _client.invoke<GetWalletAddressesResponse>(
          ctx, 'PhotonService', 'GetWalletAddresses', request, GetWalletAddressesResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
