// This is a generated file - do not edit.
//
// Generated from wallet/v1/wallet.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import '../../bitwindowd/v1/bitwindowd.pb.dart' as $1;
import 'wallet.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'wallet.pbenum.dart';

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest({
    $core.String? walletId,
  }) {
    final result = GetBalanceRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetBalanceRequest._();

  factory GetBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromBuffer(data, registry);
  factory GetBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetBalanceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
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

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? walletId,
    AddressType? addressType,
  }) {
    final result = GetNewAddressRequest._();
    if (walletId != null) result.walletId = walletId;
    if (addressType != null) result.addressType = addressType;
    return result;
  }

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetNewAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aE<AddressType>(2, _omitFieldNames ? '' : 'addressType', enumValues: AddressType.values)
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

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  AddressType get addressType => $_getN(1);
  @$pb.TagNumber(2)
  set addressType(AddressType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAddressType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddressType() => $_clearField(2);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
    $core.int? index,
  }) {
    final result = GetNewAddressResponse._();
    if (address != null) result.address = address;
    if (index != null) result.index = index;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetNewAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aI(2, _omitFieldNames ? '' : 'index', fieldType: $pb.PbFieldType.OU3)
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

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? walletId,
  }) {
    final result = ListTransactionsRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsRequest() / ListTransactionsRequest.new instead')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => ListTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(ListTransactionsRequest.$_createMessage);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? walletId,
  }) {
    final result = ListUnspentRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListUnspentRequest._();

  factory ListUnspentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromBuffer(data, registry);
  factory ListUnspentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListUnspentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) =>
      super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentRequest() / ListUnspentRequest.new instead')
  static ListUnspentRequest create() => ListUnspentRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentRequest._();
  @$core.override
  ListUnspentRequest createEmptyInstance() => ListUnspentRequest._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(ListUnspentRequest.$_createMessage);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ListReceiveAddressesRequest extends $pb.GeneratedMessage {
  factory ListReceiveAddressesRequest({
    $core.String? walletId,
  }) {
    final result = ListReceiveAddressesRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListReceiveAddressesRequest._();

  factory ListReceiveAddressesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesRequest()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListReceiveAddressesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest copyWith(void Function(ListReceiveAddressesRequest) updates) =>
      super.copyWith((message) => updates(message as ListReceiveAddressesRequest)) as ListReceiveAddressesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListReceiveAddressesRequest() / ListReceiveAddressesRequest.new instead')
  static ListReceiveAddressesRequest create() => ListReceiveAddressesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListReceiveAddressesRequest._();
  @$core.override
  ListReceiveAddressesRequest createEmptyInstance() => ListReceiveAddressesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesRequest>(ListReceiveAddressesRequest.$_createMessage);
  static ListReceiveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class GetStatsRequest extends $pb.GeneratedMessage {
  factory GetStatsRequest({
    $core.String? walletId,
  }) {
    final result = GetStatsRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetStatsRequest._();

  factory GetStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsRequest()..mergeFromBuffer(data, registry);
  factory GetStatsRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetStatsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatsRequest)) as GetStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStatsRequest() / GetStatsRequest.new instead')
  static GetStatsRequest create() => GetStatsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetStatsRequest._();
  @$core.override
  GetStatsRequest createEmptyInstance() => GetStatsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(GetStatsRequest.$_createMessage);
  static GetStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.String? walletId,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? destinations,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? fixedFeeSats,
    $core.String? opReturnMessage,
    $core.String? label,
    $core.Iterable<UnspentOutput>? requiredInputs,
  }) {
    final result = SendTransactionRequest._();
    if (walletId != null) result.walletId = walletId;
    if (destinations != null) result.destinations.addEntries(destinations);
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    if (fixedFeeSats != null) result.fixedFeeSats = fixedFeeSats;
    if (opReturnMessage != null) result.opReturnMessage = opReturnMessage;
    if (label != null) result.label = label;
    if (requiredInputs != null) result.requiredInputs.addAll(requiredInputs);
    return result;
  }

  SendTransactionRequest._();

  factory SendTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionRequest()..mergeFromBuffer(data, registry);
  factory SendTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SendTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'SendTransactionRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OU6,
        packageName: const $pb.PackageName('wallet.v1'))
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'fixedFeeSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'opReturnMessage')
    ..aOS(6, _omitFieldNames ? '' : 'label')
    ..pPM<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs', subBuilder: UnspentOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest copyWith(void Function(SendTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SendTransactionRequest)) as SendTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendTransactionRequest() / SendTransactionRequest.new instead')
  static SendTransactionRequest create() => SendTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendTransactionRequest._();
  @$core.override
  SendTransactionRequest createEmptyInstance() => SendTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest>(SendTransactionRequest.$_createMessage);
  static SendTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// Map of destination address to amount in satoshi.
  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  /// Fee rate, measured in sat/vb. If set to zero, a reasonable
  /// rate is used by asking Core for an estimate.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatPerVbyte() => $_clearField(3);

  /// Hard-coded amount, in sats.
  @$pb.TagNumber(4)
  $fixnum.Int64 get fixedFeeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set fixedFeeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFixedFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFixedFeeSats() => $_clearField(4);

  /// Message to include as an OP_RETURN output
  @$pb.TagNumber(5)
  $core.String get opReturnMessage => $_getSZ(4);
  @$pb.TagNumber(5)
  set opReturnMessage($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOpReturnMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearOpReturnMessage() => $_clearField(5);

  /// If set, will save the address with this label in the address book
  @$pb.TagNumber(6)
  $core.String get label => $_getSZ(5);
  @$pb.TagNumber(6)
  set label($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearLabel() => $_clearField(6);

  /// UTXOs that must be included in the transaction.
  @$pb.TagNumber(7)
  $pb.PbList<UnspentOutput> get requiredInputs => $_getList(6);
}

class SendTransactionResponse extends $pb.GeneratedMessage {
  factory SendTransactionResponse({
    $core.String? txid,
  }) {
    final result = SendTransactionResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendTransactionResponse._();

  factory SendTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionResponse()..mergeFromBuffer(data, registry);
  factory SendTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SendTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse copyWith(void Function(SendTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SendTransactionResponse)) as SendTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendTransactionResponse() / SendTransactionResponse.new instead')
  static SendTransactionResponse create() => SendTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendTransactionResponse._();
  @$core.override
  SendTransactionResponse createEmptyInstance() => SendTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionResponse>(SendTransactionResponse.$_createMessage);
  static SendTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $fixnum.Int64? confirmedSatoshi,
    $fixnum.Int64? pendingSatoshi,
    $fixnum.Int64? immatureSatoshi,
  }) {
    final result = GetBalanceResponse._();
    if (confirmedSatoshi != null) result.confirmedSatoshi = confirmedSatoshi;
    if (pendingSatoshi != null) result.pendingSatoshi = pendingSatoshi;
    if (immatureSatoshi != null) result.immatureSatoshi = immatureSatoshi;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetBalanceResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'confirmedSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'pendingSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'immatureSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
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
  $fixnum.Int64 get confirmedSatoshi => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSatoshi($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSatoshi() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSatoshi() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSatoshi => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSatoshi($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPendingSatoshi() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSatoshi() => $_clearField(2);

  /// Coinbase outputs that cannot be spent yet. Not part of the other two.
  @$pb.TagNumber(3)
  $fixnum.Int64 get immatureSatoshi => $_getI64(2);
  @$pb.TagNumber(3)
  set immatureSatoshi($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImmatureSatoshi() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmatureSatoshi() => $_clearField(3);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<WalletTransaction>? transactions,
  }) {
    final result = ListTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<WalletTransaction>(1, _omitFieldNames ? '' : 'transactions', subBuilder: WalletTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsResponse() / ListTransactionsResponse.new instead')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => ListTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(ListTransactionsResponse.$_createMessage);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WalletTransaction> get transactions => $_getList(0);
}

class UnspentOutput extends $pb.GeneratedMessage {
  factory UnspentOutput({
    $core.String? output,
    $core.String? address,
    $core.String? label,
    $fixnum.Int64? valueSats,
    $core.bool? isChange,
    $0.Timestamp? receivedAt,
    $1.DenialInfo? denialInfo,
    $core.String? derivationPath,
    $core.bool? splittable,
    $core.int? height,
    $core.int? inputWeightUnits,
    $core.int? confirmations,
  }) {
    final result = UnspentOutput._();
    if (output != null) result.output = output;
    if (address != null) result.address = address;
    if (label != null) result.label = label;
    if (valueSats != null) result.valueSats = valueSats;
    if (isChange != null) result.isChange = isChange;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (denialInfo != null) result.denialInfo = denialInfo;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (splittable != null) result.splittable = splittable;
    if (height != null) result.height = height;
    if (inputWeightUnits != null) result.inputWeightUnits = inputWeightUnits;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  UnspentOutput._();

  factory UnspentOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromBuffer(data, registry);
  factory UnspentOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: UnspentOutput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'output')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'valueSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'receivedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$1.DenialInfo>(7, _omitFieldNames ? '' : 'denialInfo', subBuilder: $1.DenialInfo.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'derivationPath')
    ..aOB(9, _omitFieldNames ? '' : 'splittable')
    ..aI(10, _omitFieldNames ? '' : 'height')
    ..aI(11, _omitFieldNames ? '' : 'inputWeightUnits')
    ..aI(12, _omitFieldNames ? '' : 'confirmations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) =>
      super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnspentOutput() / UnspentOutput.new instead')
  static UnspentOutput create() => UnspentOutput._();
  static $pb.GeneratedMessage $_createMessage() => UnspentOutput._();
  @$core.override
  UnspentOutput createEmptyInstance() => UnspentOutput._();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(UnspentOutput.$_createMessage);
  static UnspentOutput? _defaultInstance;

  /// The vout:index of the utxo
  @$pb.TagNumber(1)
  $core.String get output => $_getSZ(0);
  @$pb.TagNumber(1)
  set output($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutput() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutput() => $_clearField(1);

  /// What address the utxo was received to.
  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  /// What label (if any) the address received to is labeled with.
  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  /// The value of the output, in satoshis.
  @$pb.TagNumber(4)
  $fixnum.Int64 get valueSats => $_getI64(3);
  @$pb.TagNumber(4)
  set valueSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValueSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearValueSats() => $_clearField(4);

  /// Whether this is a change output.
  @$pb.TagNumber(5)
  $core.bool get isChange => $_getBF(4);
  @$pb.TagNumber(5)
  set isChange($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsChange() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsChange() => $_clearField(5);

  /// Timestamp of the utxo.
  @$pb.TagNumber(6)
  $0.Timestamp get receivedAt => $_getN(5);
  @$pb.TagNumber(6)
  set receivedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasReceivedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureReceivedAt() => $_ensure(5);

  /// If set, this utxo is part of a denial chain
  @$pb.TagNumber(7)
  $1.DenialInfo get denialInfo => $_getN(6);
  @$pb.TagNumber(7)
  set denialInfo($1.DenialInfo value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDenialInfo() => $_has(6);
  @$pb.TagNumber(7)
  void clearDenialInfo() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.DenialInfo ensureDenialInfo() => $_ensure(6);

  /// BIP32 path of the address that owns this output; empty when unknown.
  @$pb.TagNumber(8)
  $core.String get derivationPath => $_getSZ(7);
  @$pb.TagNumber(8)
  set derivationPath($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDerivationPath() => $_has(7);
  @$pb.TagNumber(8)
  void clearDerivationPath() => $_clearField(8);

  /// True when the outpoint exists unspent on BTC mainnet. Unset until the
  /// split engine checked it.
  @$pb.TagNumber(9)
  $core.bool get splittable => $_getBF(8);
  @$pb.TagNumber(9)
  set splittable($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSplittable() => $_has(8);
  @$pb.TagNumber(9)
  void clearSplittable() => $_clearField(9);

  /// Confirmation block height; 0 when unconfirmed or unknown.
  @$pb.TagNumber(10)
  $core.int get height => $_getIZ(9);
  @$pb.TagNumber(10)
  set height($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHeight() => $_has(9);
  @$pb.TagNumber(10)
  void clearHeight() => $_clearField(10);

  /// The largest weight, in weight units, that spending this output costs. 0
  /// when the backend cannot report the output's descriptor.
  @$pb.TagNumber(11)
  $core.int get inputWeightUnits => $_getIZ(10);
  @$pb.TagNumber(11)
  set inputWeightUnits($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasInputWeightUnits() => $_has(10);
  @$pb.TagNumber(11)
  void clearInputWeightUnits() => $_clearField(11);

  /// Blocks that bury the output. 0 while it waits in the mempool.
  @$pb.TagNumber(12)
  $core.int get confirmations => $_getIZ(11);
  @$pb.TagNumber(12)
  set confirmations($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasConfirmations() => $_has(11);
  @$pb.TagNumber(12)
  void clearConfirmations() => $_clearField(12);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? utxos,
  }) {
    final result = ListUnspentResponse._();
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  ListUnspentResponse._();

  factory ListUnspentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromBuffer(data, registry);
  factory ListUnspentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListUnspentResponse.$_createMessage)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'utxos', subBuilder: UnspentOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) =>
      super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentResponse() / ListUnspentResponse.new instead')
  static ListUnspentResponse create() => ListUnspentResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentResponse._();
  @$core.override
  ListUnspentResponse createEmptyInstance() => ListUnspentResponse._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(ListUnspentResponse.$_createMessage);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnspentOutput> get utxos => $_getList(0);
}

class ListReceiveAddressesResponse extends $pb.GeneratedMessage {
  factory ListReceiveAddressesResponse({
    $core.Iterable<ReceiveAddress>? addresses,
  }) {
    final result = ListReceiveAddressesResponse._();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  ListReceiveAddressesResponse._();

  factory ListReceiveAddressesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesResponse()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListReceiveAddressesResponse.$_createMessage)
    ..pPM<ReceiveAddress>(1, _omitFieldNames ? '' : 'addresses', subBuilder: ReceiveAddress.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse copyWith(void Function(ListReceiveAddressesResponse) updates) =>
      super.copyWith((message) => updates(message as ListReceiveAddressesResponse)) as ListReceiveAddressesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListReceiveAddressesResponse() / ListReceiveAddressesResponse.new instead')
  static ListReceiveAddressesResponse create() => ListReceiveAddressesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListReceiveAddressesResponse._();
  @$core.override
  ListReceiveAddressesResponse createEmptyInstance() => ListReceiveAddressesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesResponse>(ListReceiveAddressesResponse.$_createMessage);
  static ListReceiveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ReceiveAddress> get addresses => $_getList(0);
}

class ReceiveAddress extends $pb.GeneratedMessage {
  factory ReceiveAddress({
    $core.String? address,
    $core.String? label,
    $fixnum.Int64? currentBalanceSat,
    $core.bool? isChange,
    $0.Timestamp? lastUsedAt,
    $core.String? derivationPath,
  }) {
    final result = ReceiveAddress._();
    if (address != null) result.address = address;
    if (label != null) result.label = label;
    if (currentBalanceSat != null) result.currentBalanceSat = currentBalanceSat;
    if (isChange != null) result.isChange = isChange;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  ReceiveAddress._();

  factory ReceiveAddress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveAddress()..mergeFromBuffer(data, registry);
  factory ReceiveAddress.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveAddress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReceiveAddress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ReceiveAddress.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'currentBalanceSat', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastUsedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress copyWith(void Function(ReceiveAddress) updates) =>
      super.copyWith((message) => updates(message as ReceiveAddress)) as ReceiveAddress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReceiveAddress() / ReceiveAddress.new instead')
  static ReceiveAddress create() => ReceiveAddress._();
  static $pb.GeneratedMessage $_createMessage() => ReceiveAddress._();
  @$core.override
  ReceiveAddress createEmptyInstance() => ReceiveAddress._();
  @$core.pragma('dart2js:noInline')
  static ReceiveAddress getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReceiveAddress>(ReceiveAddress.$_createMessage);
  static ReceiveAddress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get currentBalanceSat => $_getI64(2);
  @$pb.TagNumber(3)
  set currentBalanceSat($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentBalanceSat() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentBalanceSat() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isChange => $_getBF(3);
  @$pb.TagNumber(4)
  set isChange($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsChange() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsChange() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get lastUsedAt => $_getN(4);
  @$pb.TagNumber(5)
  set lastUsedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastUsedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastUsedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLastUsedAt() => $_ensure(4);

  /// BIP32 path this address derives from; empty when unknown.
  @$pb.TagNumber(6)
  $core.String get derivationPath => $_getSZ(5);
  @$pb.TagNumber(6)
  set derivationPath($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDerivationPath() => $_has(5);
  @$pb.TagNumber(6)
  void clearDerivationPath() => $_clearField(6);
}

class Confirmation extends $pb.GeneratedMessage {
  factory Confirmation({
    $core.int? height,
    $0.Timestamp? timestamp,
  }) {
    final result = Confirmation._();
    if (height != null) result.height = height;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  Confirmation._();

  factory Confirmation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Confirmation()..mergeFromBuffer(data, registry);
  factory Confirmation.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Confirmation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Confirmation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: Confirmation.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Confirmation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Confirmation copyWith(void Function(Confirmation) updates) =>
      super.copyWith((message) => updates(message as Confirmation)) as Confirmation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Confirmation() / Confirmation.new instead')
  static Confirmation create() => Confirmation._();
  static $pb.GeneratedMessage $_createMessage() => Confirmation._();
  @$core.override
  Confirmation createEmptyInstance() => Confirmation._();
  @$core.pragma('dart2js:noInline')
  static Confirmation getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Confirmation>(Confirmation.$_createMessage);
  static Confirmation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

class WalletTransaction extends $pb.GeneratedMessage {
  factory WalletTransaction({
    $core.String? txid,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? receivedSatoshi,
    $fixnum.Int64? sentSatoshi,
    $core.String? address,
    $core.String? addressLabel,
    $core.String? note,
    Confirmation? confirmationTime,
    BmmBid? bmmBid,
    $core.String? warningMessage,
    $core.bool? immature,
    DepositRequest? depositRequest,
  }) {
    final result = WalletTransaction._();
    if (txid != null) result.txid = txid;
    if (feeSats != null) result.feeSats = feeSats;
    if (receivedSatoshi != null) result.receivedSatoshi = receivedSatoshi;
    if (sentSatoshi != null) result.sentSatoshi = sentSatoshi;
    if (address != null) result.address = address;
    if (addressLabel != null) result.addressLabel = addressLabel;
    if (note != null) result.note = note;
    if (confirmationTime != null) result.confirmationTime = confirmationTime;
    if (bmmBid != null) result.bmmBid = bmmBid;
    if (warningMessage != null) result.warningMessage = warningMessage;
    if (immature != null) result.immature = immature;
    if (depositRequest != null) result.depositRequest = depositRequest;
    return result;
  }

  WalletTransaction._();

  factory WalletTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletTransaction()..mergeFromBuffer(data, registry);
  factory WalletTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: WalletTransaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'receivedSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sentSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'address')
    ..aOS(6, _omitFieldNames ? '' : 'addressLabel')
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..aOM<Confirmation>(8, _omitFieldNames ? '' : 'confirmationTime', subBuilder: Confirmation.$_createMessage)
    ..aOM<BmmBid>(9, _omitFieldNames ? '' : 'bmmBid', subBuilder: BmmBid.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'warningMessage')
    ..aOB(11, _omitFieldNames ? '' : 'immature')
    ..aOM<DepositRequest>(12, _omitFieldNames ? '' : 'depositRequest', subBuilder: DepositRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletTransaction copyWith(void Function(WalletTransaction) updates) =>
      super.copyWith((message) => updates(message as WalletTransaction)) as WalletTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WalletTransaction() / WalletTransaction.new instead')
  static WalletTransaction create() => WalletTransaction._();
  static $pb.GeneratedMessage $_createMessage() => WalletTransaction._();
  @$core.override
  WalletTransaction createEmptyInstance() => WalletTransaction._();
  @$core.pragma('dart2js:noInline')
  static WalletTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletTransaction>(WalletTransaction.$_createMessage);
  static WalletTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get receivedSatoshi => $_getI64(2);
  @$pb.TagNumber(3)
  set receivedSatoshi($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReceivedSatoshi() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedSatoshi() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sentSatoshi => $_getI64(3);
  @$pb.TagNumber(4)
  set sentSatoshi($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSentSatoshi() => $_has(3);
  @$pb.TagNumber(4)
  void clearSentSatoshi() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get address => $_getSZ(4);
  @$pb.TagNumber(5)
  set address($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get addressLabel => $_getSZ(5);
  @$pb.TagNumber(6)
  set addressLabel($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAddressLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddressLabel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => $_clearField(7);

  @$pb.TagNumber(8)
  Confirmation get confirmationTime => $_getN(7);
  @$pb.TagNumber(8)
  set confirmationTime(Confirmation value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasConfirmationTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmationTime() => $_clearField(8);
  @$pb.TagNumber(8)
  Confirmation ensureConfirmationTime() => $_ensure(7);

  /// Set when output 0 carries a BMM request. Unset for every other transaction.
  @$pb.TagNumber(9)
  BmmBid get bmmBid => $_getN(8);
  @$pb.TagNumber(9)
  set bmmBid(BmmBid value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBmmBid() => $_has(8);
  @$pb.TagNumber(9)
  void clearBmmBid() => $_clearField(9);
  @$pb.TagNumber(9)
  BmmBid ensureBmmBid() => $_ensure(8);

  /// A backend warning for this transaction. Empty means no warning.
  @$pb.TagNumber(10)
  $core.String get warningMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set warningMessage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWarningMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearWarningMessage() => $_clearField(10);

  /// True for a coinbase transaction whose outputs cannot be spent yet.
  @$pb.TagNumber(11)
  $core.bool get immature => $_getBF(10);
  @$pb.TagNumber(11)
  set immature($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasImmature() => $_has(10);
  @$pb.TagNumber(11)
  void clearImmature() => $_clearField(11);

  /// Set when the transaction is a sidechain deposit request this install made.
  @$pb.TagNumber(12)
  DepositRequest get depositRequest => $_getN(11);
  @$pb.TagNumber(12)
  set depositRequest(DepositRequest value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasDepositRequest() => $_has(11);
  @$pb.TagNumber(12)
  void clearDepositRequest() => $_clearField(12);
  @$pb.TagNumber(12)
  DepositRequest ensureDepositRequest() => $_ensure(11);
}

/// DepositRequest names the sidechain a deposit request pays into.
class DepositRequest extends $pb.GeneratedMessage {
  factory DepositRequest({
    $core.int? slot,
    $core.String? destination,
  }) {
    final result = DepositRequest._();
    if (slot != null) result.slot = slot;
    if (destination != null) result.destination = destination;
    return result;
  }

  DepositRequest._();

  factory DepositRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRequest()..mergeFromBuffer(data, registry);
  factory DepositRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: DepositRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'destination')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRequest copyWith(void Function(DepositRequest) updates) =>
      super.copyWith((message) => updates(message as DepositRequest)) as DepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DepositRequest() / DepositRequest.new instead')
  static DepositRequest create() => DepositRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepositRequest._();
  @$core.override
  DepositRequest createEmptyInstance() => DepositRequest._();
  @$core.pragma('dart2js:noInline')
  static DepositRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositRequest>(DepositRequest.$_createMessage);
  static DepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  /// Sidechain address the deposit credits.
  @$pb.TagNumber(2)
  $core.String get destination => $_getSZ(1);
  @$pb.TagNumber(2)
  set destination($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDestination() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestination() => $_clearField(2);
}

/// BmmBid names the BMM request one wallet transaction carries.
class BmmBid extends $pb.GeneratedMessage {
  factory BmmBid({
    $core.int? slot,
    $core.String? criticalHash,
    $core.String? prevMainHash,
    $core.bool? lost,
  }) {
    final result = BmmBid._();
    if (slot != null) result.slot = slot;
    if (criticalHash != null) result.criticalHash = criticalHash;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    if (lost != null) result.lost = lost;
    return result;
  }

  BmmBid._();

  factory BmmBid.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BmmBid()..mergeFromBuffer(data, registry);
  factory BmmBid.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BmmBid()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BmmBid',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: BmmBid.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(3, _omitFieldNames ? '' : 'prevMainHash')
    ..aOB(4, _omitFieldNames ? '' : 'lost')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BmmBid clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BmmBid copyWith(void Function(BmmBid) updates) => super.copyWith((message) => updates(message as BmmBid)) as BmmBid;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BmmBid() / BmmBid.new instead')
  static BmmBid create() => BmmBid._();
  static $pb.GeneratedMessage $_createMessage() => BmmBid._();
  @$core.override
  BmmBid createEmptyInstance() => BmmBid._();
  @$core.pragma('dart2js:noInline')
  static BmmBid getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BmmBid>(BmmBid.$_createMessage);
  static BmmBid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => $_clearField(2);

  /// The mainchain block the sidechain block builds on. The bid reaches only
  /// the block after it.
  @$pb.TagNumber(3)
  $core.String get prevMainHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevMainHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevMainHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevMainHash() => $_clearField(3);

  /// True when the mainchain tip moved past prev_main_hash.
  @$pb.TagNumber(4)
  $core.bool get lost => $_getBF(3);
  @$pb.TagNumber(4)
  set lost($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLost() => $_has(3);
  @$pb.TagNumber(4)
  void clearLost() => $_clearField(4);
}

class ListSidechainDepositsRequest extends $pb.GeneratedMessage {
  factory ListSidechainDepositsRequest({
    $core.String? walletId,
    $core.int? slot,
  }) {
    final result = ListSidechainDepositsRequest._();
    if (walletId != null) result.walletId = walletId;
    if (slot != null) result.slot = slot;
    return result;
  }

  ListSidechainDepositsRequest._();

  factory ListSidechainDepositsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsRequest()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListSidechainDepositsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'slot')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest copyWith(void Function(ListSidechainDepositsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSidechainDepositsRequest)) as ListSidechainDepositsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainDepositsRequest() / ListSidechainDepositsRequest.new instead')
  static ListSidechainDepositsRequest create() => ListSidechainDepositsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainDepositsRequest._();
  @$core.override
  ListSidechainDepositsRequest createEmptyInstance() => ListSidechainDepositsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsRequest>(ListSidechainDepositsRequest.$_createMessage);
  static ListSidechainDepositsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get slot => $_getIZ(1);
  @$pb.TagNumber(2)
  set slot($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlot() => $_clearField(2);
}

class ListSidechainDepositsResponse_SidechainDeposit extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse_SidechainDeposit({
    $core.String? txid,
    $fixnum.Int64? amount,
    $fixnum.Int64? fee,
    $core.int? confirmations,
    $core.bool? dropped,
  }) {
    final result = ListSidechainDepositsResponse_SidechainDeposit._();
    if (txid != null) result.txid = txid;
    if (amount != null) result.amount = amount;
    if (fee != null) result.fee = fee;
    if (confirmations != null) result.confirmations = confirmations;
    if (dropped != null) result.dropped = dropped;
    return result;
  }

  ListSidechainDepositsResponse_SidechainDeposit._();

  factory ListSidechainDepositsResponse_SidechainDeposit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse_SidechainDeposit()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsResponse_SidechainDeposit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse_SidechainDeposit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSidechainDepositsResponse.SidechainDeposit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListSidechainDepositsResponse_SidechainDeposit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'fee')
    ..aI(4, _omitFieldNames ? '' : 'confirmations')
    ..aOB(5, _omitFieldNames ? '' : 'dropped')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse_SidechainDeposit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse_SidechainDeposit copyWith(
          void Function(ListSidechainDepositsResponse_SidechainDeposit) updates) =>
      super.copyWith((message) => updates(message as ListSidechainDepositsResponse_SidechainDeposit))
          as ListSidechainDepositsResponse_SidechainDeposit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListSidechainDepositsResponse_SidechainDeposit() / ListSidechainDepositsResponse_SidechainDeposit.new instead')
  static ListSidechainDepositsResponse_SidechainDeposit create() => ListSidechainDepositsResponse_SidechainDeposit._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainDepositsResponse_SidechainDeposit._();
  @$core.override
  ListSidechainDepositsResponse_SidechainDeposit createEmptyInstance() =>
      ListSidechainDepositsResponse_SidechainDeposit._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse_SidechainDeposit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse_SidechainDeposit>(
          ListSidechainDepositsResponse_SidechainDeposit.$_createMessage);
  static ListSidechainDepositsResponse_SidechainDeposit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fee => $_getI64(2);
  @$pb.TagNumber(3)
  set fee($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearFee() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => $_clearField(4);

  /// True when the network no longer holds the deposit, so it can never
  /// confirm and the user must send it again.
  @$pb.TagNumber(5)
  $core.bool get dropped => $_getBF(4);
  @$pb.TagNumber(5)
  set dropped($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDropped() => $_has(4);
  @$pb.TagNumber(5)
  void clearDropped() => $_clearField(5);
}

class ListSidechainDepositsResponse extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse({
    $core.Iterable<ListSidechainDepositsResponse_SidechainDeposit>? deposits,
  }) {
    final result = ListSidechainDepositsResponse._();
    if (deposits != null) result.deposits.addAll(deposits);
    return result;
  }

  ListSidechainDepositsResponse._();

  factory ListSidechainDepositsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListSidechainDepositsResponse.$_createMessage)
    ..pPM<ListSidechainDepositsResponse_SidechainDeposit>(1, _omitFieldNames ? '' : 'deposits',
        subBuilder: ListSidechainDepositsResponse_SidechainDeposit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse copyWith(void Function(ListSidechainDepositsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSidechainDepositsResponse)) as ListSidechainDepositsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainDepositsResponse() / ListSidechainDepositsResponse.new instead')
  static ListSidechainDepositsResponse create() => ListSidechainDepositsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainDepositsResponse._();
  @$core.override
  ListSidechainDepositsResponse createEmptyInstance() => ListSidechainDepositsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse>(ListSidechainDepositsResponse.$_createMessage);
  static ListSidechainDepositsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ListSidechainDepositsResponse_SidechainDeposit> get deposits => $_getList(0);
}

class CreateSidechainDepositRequest extends $pb.GeneratedMessage {
  factory CreateSidechainDepositRequest({
    $core.String? walletId,
    $fixnum.Int64? slot,
    $core.String? destination,
    $core.double? amount,
    $core.double? fee,
  }) {
    final result = CreateSidechainDepositRequest._();
    if (walletId != null) result.walletId = walletId;
    if (slot != null) result.slot = slot;
    if (destination != null) result.destination = destination;
    if (amount != null) result.amount = amount;
    if (fee != null) result.fee = fee;
    return result;
  }

  CreateSidechainDepositRequest._();

  factory CreateSidechainDepositRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSidechainDepositRequest()..mergeFromBuffer(data, registry);
  factory CreateSidechainDepositRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSidechainDepositRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainDepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CreateSidechainDepositRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'slot')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aD(4, _omitFieldNames ? '' : 'amount')
    ..aD(5, _omitFieldNames ? '' : 'fee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositRequest copyWith(void Function(CreateSidechainDepositRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSidechainDepositRequest)) as CreateSidechainDepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSidechainDepositRequest() / CreateSidechainDepositRequest.new instead')
  static CreateSidechainDepositRequest create() => CreateSidechainDepositRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateSidechainDepositRequest._();
  @$core.override
  CreateSidechainDepositRequest createEmptyInstance() => CreateSidechainDepositRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositRequest>(CreateSidechainDepositRequest.$_createMessage);
  static CreateSidechainDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(2)
  $fixnum.Int64 get slot => $_getI64(1);
  @$pb.TagNumber(2)
  set slot($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlot() => $_clearField(2);

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);

  /// The amount in BTC to send. eg 0.1
  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  /// The fee in BTC
  @$pb.TagNumber(5)
  $core.double get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => $_clearField(5);
}

class CreateSidechainDepositResponse extends $pb.GeneratedMessage {
  factory CreateSidechainDepositResponse({
    $core.String? txid,
  }) {
    final result = CreateSidechainDepositResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateSidechainDepositResponse._();

  factory CreateSidechainDepositResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSidechainDepositResponse()..mergeFromBuffer(data, registry);
  factory CreateSidechainDepositResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSidechainDepositResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainDepositResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CreateSidechainDepositResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositResponse copyWith(void Function(CreateSidechainDepositResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSidechainDepositResponse)) as CreateSidechainDepositResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSidechainDepositResponse() / CreateSidechainDepositResponse.new instead')
  static CreateSidechainDepositResponse create() => CreateSidechainDepositResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateSidechainDepositResponse._();
  @$core.override
  CreateSidechainDepositResponse createEmptyInstance() => CreateSidechainDepositResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositResponse>(CreateSidechainDepositResponse.$_createMessage);
  static CreateSidechainDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class SignMessageRequest extends $pb.GeneratedMessage {
  factory SignMessageRequest({
    $core.String? walletId,
    $core.String? message,
    $core.String? address,
  }) {
    final result = SignMessageRequest._();
    if (walletId != null) result.walletId = walletId;
    if (message != null) result.message = message;
    if (address != null) result.address = address;
    return result;
  }

  SignMessageRequest._();

  factory SignMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignMessageRequest()..mergeFromBuffer(data, registry);
  factory SignMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SignMessageRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageRequest copyWith(void Function(SignMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SignMessageRequest)) as SignMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignMessageRequest() / SignMessageRequest.new instead')
  static SignMessageRequest create() => SignMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignMessageRequest._();
  @$core.override
  SignMessageRequest createEmptyInstance() => SignMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static SignMessageRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignMessageRequest>(SignMessageRequest.$_createMessage);
  static SignMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// Receiving address to sign with. Must belong to the wallet.
  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);
}

class SignMessageResponse extends $pb.GeneratedMessage {
  factory SignMessageResponse({
    $core.String? signature,
    $core.String? publicKey,
  }) {
    final result = SignMessageResponse._();
    if (signature != null) result.signature = signature;
    if (publicKey != null) result.publicKey = publicKey;
    return result;
  }

  SignMessageResponse._();

  factory SignMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignMessageResponse()..mergeFromBuffer(data, registry);
  factory SignMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignMessageResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SignMessageResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..aOS(2, _omitFieldNames ? '' : 'publicKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageResponse copyWith(void Function(SignMessageResponse) updates) =>
      super.copyWith((message) => updates(message as SignMessageResponse)) as SignMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignMessageResponse() / SignMessageResponse.new instead')
  static SignMessageResponse create() => SignMessageResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignMessageResponse._();
  @$core.override
  SignMessageResponse createEmptyInstance() => SignMessageResponse._();
  @$core.pragma('dart2js:noInline')
  static SignMessageResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignMessageResponse>(SignMessageResponse.$_createMessage);
  static SignMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);

  /// Compressed public key of the signing key, hex. For taproot, the tweaked key.
  @$pb.TagNumber(2)
  $core.String get publicKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set publicKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPublicKey() => $_clearField(2);
}

class VerifyMessageRequest extends $pb.GeneratedMessage {
  factory VerifyMessageRequest({
    $core.String? walletId,
    $core.String? message,
    $core.String? signature,
    $core.String? publicKey,
    $core.String? signerPublicKey,
  }) {
    final result = VerifyMessageRequest._();
    if (walletId != null) result.walletId = walletId;
    if (message != null) result.message = message;
    if (signature != null) result.signature = signature;
    if (publicKey != null) result.publicKey = publicKey;
    if (signerPublicKey != null) result.signerPublicKey = signerPublicKey;
    return result;
  }

  VerifyMessageRequest._();

  factory VerifyMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyMessageRequest()..mergeFromBuffer(data, registry);
  factory VerifyMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: VerifyMessageRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'signature')
    ..aOS(4, _omitFieldNames ? '' : 'publicKey')
    ..aOS(5, _omitFieldNames ? '' : 'signerPublicKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageRequest copyWith(void Function(VerifyMessageRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyMessageRequest)) as VerifyMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifyMessageRequest() / VerifyMessageRequest.new instead')
  static VerifyMessageRequest create() => VerifyMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => VerifyMessageRequest._();
  @$core.override
  VerifyMessageRequest createEmptyInstance() => VerifyMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyMessageRequest>(VerifyMessageRequest.$_createMessage);
  static VerifyMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get signature => $_getSZ(2);
  @$pb.TagNumber(3)
  set signature($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get publicKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicKey() => $_clearField(4);

  /// Optional hex public key that must own the address in public_key.
  @$pb.TagNumber(5)
  $core.String get signerPublicKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set signerPublicKey($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSignerPublicKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignerPublicKey() => $_clearField(5);
}

class VerifyMessageResponse extends $pb.GeneratedMessage {
  factory VerifyMessageResponse({
    $core.bool? valid,
  }) {
    final result = VerifyMessageResponse._();
    if (valid != null) result.valid = valid;
    return result;
  }

  VerifyMessageResponse._();

  factory VerifyMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyMessageResponse()..mergeFromBuffer(data, registry);
  factory VerifyMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyMessageResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: VerifyMessageResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageResponse copyWith(void Function(VerifyMessageResponse) updates) =>
      super.copyWith((message) => updates(message as VerifyMessageResponse)) as VerifyMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifyMessageResponse() / VerifyMessageResponse.new instead')
  static VerifyMessageResponse create() => VerifyMessageResponse._();
  static $pb.GeneratedMessage $_createMessage() => VerifyMessageResponse._();
  @$core.override
  VerifyMessageResponse createEmptyInstance() => VerifyMessageResponse._();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyMessageResponse>(VerifyMessageResponse.$_createMessage);
  static VerifyMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);
}

class GetStatsResponse extends $pb.GeneratedMessage {
  factory GetStatsResponse({
    $fixnum.Int64? utxosCurrent,
    $fixnum.Int64? utxosUniqueAddresses,
    $fixnum.Int64? sidechainDepositVolume,
    $fixnum.Int64? sidechainDepositVolumeLast30Days,
    $fixnum.Int64? transactionCountTotal,
    $fixnum.Int64? transactionCountSinceMonth,
    $fixnum.Int64? totalFeesSats,
    $0.Timestamp? lastTxAt,
    $core.int? lastTxBlockHeight,
  }) {
    final result = GetStatsResponse._();
    if (utxosCurrent != null) result.utxosCurrent = utxosCurrent;
    if (utxosUniqueAddresses != null) result.utxosUniqueAddresses = utxosUniqueAddresses;
    if (sidechainDepositVolume != null) result.sidechainDepositVolume = sidechainDepositVolume;
    if (sidechainDepositVolumeLast30Days != null)
      result.sidechainDepositVolumeLast30Days = sidechainDepositVolumeLast30Days;
    if (transactionCountTotal != null) result.transactionCountTotal = transactionCountTotal;
    if (transactionCountSinceMonth != null) result.transactionCountSinceMonth = transactionCountSinceMonth;
    if (totalFeesSats != null) result.totalFeesSats = totalFeesSats;
    if (lastTxAt != null) result.lastTxAt = lastTxAt;
    if (lastTxBlockHeight != null) result.lastTxBlockHeight = lastTxBlockHeight;
    return result;
  }

  GetStatsResponse._();

  factory GetStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsResponse()..mergeFromBuffer(data, registry);
  factory GetStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetStatsResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'utxosCurrent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'utxosUniqueAddresses', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'sidechainDepositVolume')
    ..aInt64(4, _omitFieldNames ? '' : 'sidechainDepositVolumeLast30Days',
        protoName: 'sidechain_deposit_volume_last_30_days')
    ..aInt64(5, _omitFieldNames ? '' : 'transactionCountTotal')
    ..aInt64(6, _omitFieldNames ? '' : 'transactionCountSinceMonth')
    ..aInt64(7, _omitFieldNames ? '' : 'totalFeesSats')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'lastTxAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(9, _omitFieldNames ? '' : 'lastTxBlockHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse copyWith(void Function(GetStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatsResponse)) as GetStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStatsResponse() / GetStatsResponse.new instead')
  static GetStatsResponse create() => GetStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetStatsResponse._();
  @$core.override
  GetStatsResponse createEmptyInstance() => GetStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetStatsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsResponse>(GetStatsResponse.$_createMessage);
  static GetStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get utxosCurrent => $_getI64(0);
  @$pb.TagNumber(1)
  set utxosCurrent($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUtxosCurrent() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosCurrent() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get utxosUniqueAddresses => $_getI64(1);
  @$pb.TagNumber(2)
  set utxosUniqueAddresses($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUtxosUniqueAddresses() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxosUniqueAddresses() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sidechainDepositVolume => $_getI64(2);
  @$pb.TagNumber(3)
  set sidechainDepositVolume($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSidechainDepositVolume() => $_has(2);
  @$pb.TagNumber(3)
  void clearSidechainDepositVolume() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sidechainDepositVolumeLast30Days => $_getI64(3);
  @$pb.TagNumber(4)
  set sidechainDepositVolumeLast30Days($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSidechainDepositVolumeLast30Days() => $_has(3);
  @$pb.TagNumber(4)
  void clearSidechainDepositVolumeLast30Days() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get transactionCountTotal => $_getI64(4);
  @$pb.TagNumber(5)
  set transactionCountTotal($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTransactionCountTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearTransactionCountTotal() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get transactionCountSinceMonth => $_getI64(5);
  @$pb.TagNumber(6)
  set transactionCountSinceMonth($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTransactionCountSinceMonth() => $_has(5);
  @$pb.TagNumber(6)
  void clearTransactionCountSinceMonth() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get totalFeesSats => $_getI64(6);
  @$pb.TagNumber(7)
  set totalFeesSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalFeesSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalFeesSats() => $_clearField(7);

  /// Most-recent confirmed transaction in the wallet. Both unset when the
  /// wallet has no confirmed transactions yet.
  @$pb.TagNumber(8)
  $0.Timestamp get lastTxAt => $_getN(7);
  @$pb.TagNumber(8)
  set lastTxAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastTxAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastTxAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureLastTxAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get lastTxBlockHeight => $_getIZ(8);
  @$pb.TagNumber(9)
  set lastTxBlockHeight($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastTxBlockHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastTxBlockHeight() => $_clearField(9);
}

/// Wallet unlock/lock messages
class UnlockWalletRequest extends $pb.GeneratedMessage {
  factory UnlockWalletRequest({
    $core.String? password,
  }) {
    final result = UnlockWalletRequest._();
    if (password != null) result.password = password;
    return result;
  }

  UnlockWalletRequest._();

  factory UnlockWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletRequest()..mergeFromBuffer(data, registry);
  factory UnlockWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: UnlockWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest copyWith(void Function(UnlockWalletRequest) updates) =>
      super.copyWith((message) => updates(message as UnlockWalletRequest)) as UnlockWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnlockWalletRequest() / UnlockWalletRequest.new instead')
  static UnlockWalletRequest create() => UnlockWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => UnlockWalletRequest._();
  @$core.override
  UnlockWalletRequest createEmptyInstance() => UnlockWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletRequest>(UnlockWalletRequest.$_createMessage);
  static UnlockWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => $_clearField(1);
}

/// Cheque messages
class CreateChequeRequest extends $pb.GeneratedMessage {
  factory CreateChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? expectedAmountSats,
  }) {
    final result = CreateChequeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (expectedAmountSats != null) result.expectedAmountSats = expectedAmountSats;
    return result;
  }

  CreateChequeRequest._();

  factory CreateChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChequeRequest()..mergeFromBuffer(data, registry);
  factory CreateChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChequeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CreateChequeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeRequest copyWith(void Function(CreateChequeRequest) updates) =>
      super.copyWith((message) => updates(message as CreateChequeRequest)) as CreateChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateChequeRequest() / CreateChequeRequest.new instead')
  static CreateChequeRequest create() => CreateChequeRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateChequeRequest._();
  @$core.override
  CreateChequeRequest createEmptyInstance() => CreateChequeRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateChequeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateChequeRequest>(CreateChequeRequest.$_createMessage);
  static CreateChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedAmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedAmountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedAmountSats() => $_clearField(2);
}

class CreateChequeResponse extends $pb.GeneratedMessage {
  factory CreateChequeResponse({
    $fixnum.Int64? id,
    $core.String? address,
    $core.int? derivationIndex,
  }) {
    final result = CreateChequeResponse._();
    if (id != null) result.id = id;
    if (address != null) result.address = address;
    if (derivationIndex != null) result.derivationIndex = derivationIndex;
    return result;
  }

  CreateChequeResponse._();

  factory CreateChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChequeResponse()..mergeFromBuffer(data, registry);
  factory CreateChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChequeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CreateChequeResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aI(3, _omitFieldNames ? '' : 'derivationIndex', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeResponse copyWith(void Function(CreateChequeResponse) updates) =>
      super.copyWith((message) => updates(message as CreateChequeResponse)) as CreateChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateChequeResponse() / CreateChequeResponse.new instead')
  static CreateChequeResponse create() => CreateChequeResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateChequeResponse._();
  @$core.override
  CreateChequeResponse createEmptyInstance() => CreateChequeResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateChequeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChequeResponse>(CreateChequeResponse.$_createMessage);
  static CreateChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get derivationIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set derivationIndex($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDerivationIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationIndex() => $_clearField(3);
}

class GetChequeRequest extends $pb.GeneratedMessage {
  factory GetChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = GetChequeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  GetChequeRequest._();

  factory GetChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequeRequest()..mergeFromBuffer(data, registry);
  factory GetChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetChequeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeRequest copyWith(void Function(GetChequeRequest) updates) =>
      super.copyWith((message) => updates(message as GetChequeRequest)) as GetChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChequeRequest() / GetChequeRequest.new instead')
  static GetChequeRequest create() => GetChequeRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetChequeRequest._();
  @$core.override
  GetChequeRequest createEmptyInstance() => GetChequeRequest._();
  @$core.pragma('dart2js:noInline')
  static GetChequeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequeRequest>(GetChequeRequest.$_createMessage);
  static GetChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class GetChequeResponse extends $pb.GeneratedMessage {
  factory GetChequeResponse({
    Cheque? cheque,
  }) {
    final result = GetChequeResponse._();
    if (cheque != null) result.cheque = cheque;
    return result;
  }

  GetChequeResponse._();

  factory GetChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequeResponse()..mergeFromBuffer(data, registry);
  factory GetChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetChequeResponse.$_createMessage)
    ..aOM<Cheque>(1, _omitFieldNames ? '' : 'cheque', subBuilder: Cheque.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeResponse copyWith(void Function(GetChequeResponse) updates) =>
      super.copyWith((message) => updates(message as GetChequeResponse)) as GetChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChequeResponse() / GetChequeResponse.new instead')
  static GetChequeResponse create() => GetChequeResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetChequeResponse._();
  @$core.override
  GetChequeResponse createEmptyInstance() => GetChequeResponse._();
  @$core.pragma('dart2js:noInline')
  static GetChequeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequeResponse>(GetChequeResponse.$_createMessage);
  static GetChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cheque get cheque => $_getN(0);
  @$pb.TagNumber(1)
  set cheque(Cheque value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCheque() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheque() => $_clearField(1);
  @$pb.TagNumber(1)
  Cheque ensureCheque() => $_ensure(0);
}

class GetChequePrivateKeyRequest extends $pb.GeneratedMessage {
  factory GetChequePrivateKeyRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = GetChequePrivateKeyRequest._();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  GetChequePrivateKeyRequest._();

  factory GetChequePrivateKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequePrivateKeyRequest()..mergeFromBuffer(data, registry);
  factory GetChequePrivateKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequePrivateKeyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequePrivateKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetChequePrivateKeyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyRequest copyWith(void Function(GetChequePrivateKeyRequest) updates) =>
      super.copyWith((message) => updates(message as GetChequePrivateKeyRequest)) as GetChequePrivateKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChequePrivateKeyRequest() / GetChequePrivateKeyRequest.new instead')
  static GetChequePrivateKeyRequest create() => GetChequePrivateKeyRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetChequePrivateKeyRequest._();
  @$core.override
  GetChequePrivateKeyRequest createEmptyInstance() => GetChequePrivateKeyRequest._();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyRequest>(GetChequePrivateKeyRequest.$_createMessage);
  static GetChequePrivateKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class GetChequePrivateKeyResponse extends $pb.GeneratedMessage {
  factory GetChequePrivateKeyResponse({
    $core.String? privateKeyWif,
  }) {
    final result = GetChequePrivateKeyResponse._();
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    return result;
  }

  GetChequePrivateKeyResponse._();

  factory GetChequePrivateKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequePrivateKeyResponse()..mergeFromBuffer(data, registry);
  factory GetChequePrivateKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChequePrivateKeyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequePrivateKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetChequePrivateKeyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyResponse copyWith(void Function(GetChequePrivateKeyResponse) updates) =>
      super.copyWith((message) => updates(message as GetChequePrivateKeyResponse)) as GetChequePrivateKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChequePrivateKeyResponse() / GetChequePrivateKeyResponse.new instead')
  static GetChequePrivateKeyResponse create() => GetChequePrivateKeyResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetChequePrivateKeyResponse._();
  @$core.override
  GetChequePrivateKeyResponse createEmptyInstance() => GetChequePrivateKeyResponse._();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyResponse>(GetChequePrivateKeyResponse.$_createMessage);
  static GetChequePrivateKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyWif => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyWif($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyWif() => $_clearField(1);
}

class Cheque extends $pb.GeneratedMessage {
  factory Cheque({
    $fixnum.Int64? id,
    $core.int? derivationIndex,
    $core.String? address,
    $fixnum.Int64? expectedAmountSats,
    $core.bool? funded,
    $core.Iterable<$core.String>? fundedTxids,
    $fixnum.Int64? actualAmountSats,
    $0.Timestamp? createdAt,
    $0.Timestamp? fundedAt,
    $core.String? privateKeyWif,
    $core.String? sweptTxid,
    $0.Timestamp? sweptAt,
  }) {
    final result = Cheque._();
    if (id != null) result.id = id;
    if (derivationIndex != null) result.derivationIndex = derivationIndex;
    if (address != null) result.address = address;
    if (expectedAmountSats != null) result.expectedAmountSats = expectedAmountSats;
    if (funded != null) result.funded = funded;
    if (fundedTxids != null) result.fundedTxids.addAll(fundedTxids);
    if (actualAmountSats != null) result.actualAmountSats = actualAmountSats;
    if (createdAt != null) result.createdAt = createdAt;
    if (fundedAt != null) result.fundedAt = fundedAt;
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (sweptTxid != null) result.sweptTxid = sweptTxid;
    if (sweptAt != null) result.sweptAt = sweptAt;
    return result;
  }

  Cheque._();

  factory Cheque.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Cheque()..mergeFromBuffer(data, registry);
  factory Cheque.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Cheque()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Cheque',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: Cheque.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'derivationIndex', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'funded')
    ..pPS(6, _omitFieldNames ? '' : 'fundedTxids')
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'fundedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(11, _omitFieldNames ? '' : 'sweptTxid')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'sweptAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cheque clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cheque copyWith(void Function(Cheque) updates) => super.copyWith((message) => updates(message as Cheque)) as Cheque;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Cheque() / Cheque.new instead')
  static Cheque create() => Cheque._();
  static $pb.GeneratedMessage $_createMessage() => Cheque._();
  @$core.override
  Cheque createEmptyInstance() => Cheque._();
  @$core.pragma('dart2js:noInline')
  static Cheque getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cheque>(Cheque.$_createMessage);
  static Cheque? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get derivationIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set derivationIndex($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDerivationIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expectedAmountSats => $_getI64(3);
  @$pb.TagNumber(4)
  set expectedAmountSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedAmountSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedAmountSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get funded => $_getBF(4);
  @$pb.TagNumber(5)
  set funded($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFunded() => $_has(4);
  @$pb.TagNumber(5)
  void clearFunded() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get fundedTxids => $_getList(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get actualAmountSats => $_getI64(6);
  @$pb.TagNumber(7)
  set actualAmountSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActualAmountSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearActualAmountSats() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get fundedAt => $_getN(8);
  @$pb.TagNumber(9)
  set fundedAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasFundedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearFundedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureFundedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get privateKeyWif => $_getSZ(9);
  @$pb.TagNumber(10)
  set privateKeyWif($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPrivateKeyWif() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrivateKeyWif() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get sweptTxid => $_getSZ(10);
  @$pb.TagNumber(11)
  set sweptTxid($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSweptTxid() => $_has(10);
  @$pb.TagNumber(11)
  void clearSweptTxid() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get sweptAt => $_getN(11);
  @$pb.TagNumber(12)
  set sweptAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSweptAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearSweptAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureSweptAt() => $_ensure(11);
}

class ListChequesRequest extends $pb.GeneratedMessage {
  factory ListChequesRequest({
    $core.String? walletId,
  }) {
    final result = ListChequesRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListChequesRequest._();

  factory ListChequesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListChequesRequest()..mergeFromBuffer(data, registry);
  factory ListChequesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListChequesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListChequesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListChequesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesRequest copyWith(void Function(ListChequesRequest) updates) =>
      super.copyWith((message) => updates(message as ListChequesRequest)) as ListChequesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListChequesRequest() / ListChequesRequest.new instead')
  static ListChequesRequest create() => ListChequesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListChequesRequest._();
  @$core.override
  ListChequesRequest createEmptyInstance() => ListChequesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListChequesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListChequesRequest>(ListChequesRequest.$_createMessage);
  static ListChequesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ListChequesResponse extends $pb.GeneratedMessage {
  factory ListChequesResponse({
    $core.Iterable<Cheque>? cheques,
  }) {
    final result = ListChequesResponse._();
    if (cheques != null) result.cheques.addAll(cheques);
    return result;
  }

  ListChequesResponse._();

  factory ListChequesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListChequesResponse()..mergeFromBuffer(data, registry);
  factory ListChequesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListChequesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListChequesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ListChequesResponse.$_createMessage)
    ..pPM<Cheque>(1, _omitFieldNames ? '' : 'cheques', subBuilder: Cheque.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesResponse copyWith(void Function(ListChequesResponse) updates) =>
      super.copyWith((message) => updates(message as ListChequesResponse)) as ListChequesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListChequesResponse() / ListChequesResponse.new instead')
  static ListChequesResponse create() => ListChequesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListChequesResponse._();
  @$core.override
  ListChequesResponse createEmptyInstance() => ListChequesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListChequesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListChequesResponse>(ListChequesResponse.$_createMessage);
  static ListChequesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Cheque> get cheques => $_getList(0);
}

class CheckChequeFundingRequest extends $pb.GeneratedMessage {
  factory CheckChequeFundingRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = CheckChequeFundingRequest._();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  CheckChequeFundingRequest._();

  factory CheckChequeFundingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckChequeFundingRequest()..mergeFromBuffer(data, registry);
  factory CheckChequeFundingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckChequeFundingRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckChequeFundingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CheckChequeFundingRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingRequest copyWith(void Function(CheckChequeFundingRequest) updates) =>
      super.copyWith((message) => updates(message as CheckChequeFundingRequest)) as CheckChequeFundingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckChequeFundingRequest() / CheckChequeFundingRequest.new instead')
  static CheckChequeFundingRequest create() => CheckChequeFundingRequest._();
  static $pb.GeneratedMessage $_createMessage() => CheckChequeFundingRequest._();
  @$core.override
  CheckChequeFundingRequest createEmptyInstance() => CheckChequeFundingRequest._();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingRequest>(CheckChequeFundingRequest.$_createMessage);
  static CheckChequeFundingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class CheckChequeFundingResponse extends $pb.GeneratedMessage {
  factory CheckChequeFundingResponse({
    $core.bool? funded,
    $fixnum.Int64? actualAmountSats,
    $core.Iterable<$core.String>? fundedTxids,
    $0.Timestamp? fundedAt,
    $core.int? minConfirmations,
  }) {
    final result = CheckChequeFundingResponse._();
    if (funded != null) result.funded = funded;
    if (actualAmountSats != null) result.actualAmountSats = actualAmountSats;
    if (fundedTxids != null) result.fundedTxids.addAll(fundedTxids);
    if (fundedAt != null) result.fundedAt = fundedAt;
    if (minConfirmations != null) result.minConfirmations = minConfirmations;
    return result;
  }

  CheckChequeFundingResponse._();

  factory CheckChequeFundingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckChequeFundingResponse()..mergeFromBuffer(data, registry);
  factory CheckChequeFundingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckChequeFundingResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckChequeFundingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CheckChequeFundingResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'funded')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(3, _omitFieldNames ? '' : 'fundedTxids')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'fundedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(5, _omitFieldNames ? '' : 'minConfirmations', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingResponse copyWith(void Function(CheckChequeFundingResponse) updates) =>
      super.copyWith((message) => updates(message as CheckChequeFundingResponse)) as CheckChequeFundingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckChequeFundingResponse() / CheckChequeFundingResponse.new instead')
  static CheckChequeFundingResponse create() => CheckChequeFundingResponse._();
  static $pb.GeneratedMessage $_createMessage() => CheckChequeFundingResponse._();
  @$core.override
  CheckChequeFundingResponse createEmptyInstance() => CheckChequeFundingResponse._();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingResponse>(CheckChequeFundingResponse.$_createMessage);
  static CheckChequeFundingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get funded => $_getBF(0);
  @$pb.TagNumber(1)
  set funded($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFunded() => $_has(0);
  @$pb.TagNumber(1)
  void clearFunded() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get actualAmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set actualAmountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActualAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearActualAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get fundedTxids => $_getList(2);

  @$pb.TagNumber(4)
  $0.Timestamp get fundedAt => $_getN(3);
  @$pb.TagNumber(4)
  set fundedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFundedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearFundedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureFundedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get minConfirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set minConfirmations($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinConfirmations() => $_clearField(5);
}

class PreviewSweepRequest extends $pb.GeneratedMessage {
  factory PreviewSweepRequest({
    $core.String? privateKeyWif,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = PreviewSweepRequest._();
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  PreviewSweepRequest._();

  factory PreviewSweepRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSweepRequest()..mergeFromBuffer(data, registry);
  factory PreviewSweepRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSweepRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewSweepRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: PreviewSweepRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSweepRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSweepRequest copyWith(void Function(PreviewSweepRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewSweepRequest)) as PreviewSweepRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewSweepRequest() / PreviewSweepRequest.new instead')
  static PreviewSweepRequest create() => PreviewSweepRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSweepRequest._();
  @$core.override
  PreviewSweepRequest createEmptyInstance() => PreviewSweepRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewSweepRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewSweepRequest>(PreviewSweepRequest.$_createMessage);
  static PreviewSweepRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyWif => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyWif($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyWif() => $_clearField(1);

  /// Zero asks the backend for its own estimate.
  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSatPerVbyte() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSatPerVbyte() => $_clearField(2);
}

/// What a private key holds, and what sweeping it would cost. Reads only.
class PreviewSweepResponse extends $pb.GeneratedMessage {
  factory PreviewSweepResponse({
    $core.String? address,
    SweepAddressKind? addressKind,
    $fixnum.Int64? amountSats,
    $core.int? outputCount,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? receiveSats,
  }) {
    final result = PreviewSweepResponse._();
    if (address != null) result.address = address;
    if (addressKind != null) result.addressKind = addressKind;
    if (amountSats != null) result.amountSats = amountSats;
    if (outputCount != null) result.outputCount = outputCount;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    if (feeSats != null) result.feeSats = feeSats;
    if (receiveSats != null) result.receiveSats = receiveSats;
    return result;
  }

  PreviewSweepResponse._();

  factory PreviewSweepResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSweepResponse()..mergeFromBuffer(data, registry);
  factory PreviewSweepResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSweepResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewSweepResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: PreviewSweepResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aE<SweepAddressKind>(2, _omitFieldNames ? '' : 'addressKind', enumValues: SweepAddressKind.values)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'outputCount', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'receiveSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSweepResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSweepResponse copyWith(void Function(PreviewSweepResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewSweepResponse)) as PreviewSweepResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewSweepResponse() / PreviewSweepResponse.new instead')
  static PreviewSweepResponse create() => PreviewSweepResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSweepResponse._();
  @$core.override
  PreviewSweepResponse createEmptyInstance() => PreviewSweepResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewSweepResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewSweepResponse>(PreviewSweepResponse.$_createMessage);
  static PreviewSweepResponse? _defaultInstance;

  /// The funded address, or the P2WPKH one when the key holds nothing.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  SweepAddressKind get addressKind => $_getN(1);
  @$pb.TagNumber(2)
  set addressKind(SweepAddressKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAddressKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddressKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSats => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get outputCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set outputCount($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOutputCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearOutputCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSatPerVbyte() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSatPerVbyte() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get feeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSats() => $_clearField(6);

  /// amount_sats minus fee_sats. Zero when the fee exceeds the balance.
  @$pb.TagNumber(7)
  $fixnum.Int64 get receiveSats => $_getI64(6);
  @$pb.TagNumber(7)
  set receiveSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReceiveSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearReceiveSats() => $_clearField(7);
}

class SweepChequeRequest extends $pb.GeneratedMessage {
  factory SweepChequeRequest({
    $core.String? walletId,
    $core.String? privateKeyWif,
    $core.String? destinationAddress,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = SweepChequeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (destinationAddress != null) result.destinationAddress = destinationAddress;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  SweepChequeRequest._();

  factory SweepChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SweepChequeRequest()..mergeFromBuffer(data, registry);
  factory SweepChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SweepChequeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SweepChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SweepChequeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(3, _omitFieldNames ? '' : 'destinationAddress')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeRequest copyWith(void Function(SweepChequeRequest) updates) =>
      super.copyWith((message) => updates(message as SweepChequeRequest)) as SweepChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SweepChequeRequest() / SweepChequeRequest.new instead')
  static SweepChequeRequest create() => SweepChequeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SweepChequeRequest._();
  @$core.override
  SweepChequeRequest createEmptyInstance() => SweepChequeRequest._();
  @$core.pragma('dart2js:noInline')
  static SweepChequeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SweepChequeRequest>(SweepChequeRequest.$_createMessage);
  static SweepChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get destinationAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set destinationAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestinationAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestinationAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSatPerVbyte() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSatPerVbyte() => $_clearField(4);
}

class SweepChequeResponse extends $pb.GeneratedMessage {
  factory SweepChequeResponse({
    $core.String? txid,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = SweepChequeResponse._();
    if (txid != null) result.txid = txid;
    if (amountSats != null) result.amountSats = amountSats;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  SweepChequeResponse._();

  factory SweepChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SweepChequeResponse()..mergeFromBuffer(data, registry);
  factory SweepChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SweepChequeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SweepChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SweepChequeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeResponse copyWith(void Function(SweepChequeResponse) updates) =>
      super.copyWith((message) => updates(message as SweepChequeResponse)) as SweepChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SweepChequeResponse() / SweepChequeResponse.new instead')
  static SweepChequeResponse create() => SweepChequeResponse._();
  static $pb.GeneratedMessage $_createMessage() => SweepChequeResponse._();
  @$core.override
  SweepChequeResponse createEmptyInstance() => SweepChequeResponse._();
  @$core.pragma('dart2js:noInline')
  static SweepChequeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SweepChequeResponse>(SweepChequeResponse.$_createMessage);
  static SweepChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  /// The fee rate the sweep used, so the UI can report an estimate it did not
  /// choose.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatPerVbyte() => $_clearField(3);
}

class DeleteChequeRequest extends $pb.GeneratedMessage {
  factory DeleteChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = DeleteChequeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  DeleteChequeRequest._();

  factory DeleteChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteChequeRequest()..mergeFromBuffer(data, registry);
  factory DeleteChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteChequeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: DeleteChequeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChequeRequest copyWith(void Function(DeleteChequeRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteChequeRequest)) as DeleteChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteChequeRequest() / DeleteChequeRequest.new instead')
  static DeleteChequeRequest create() => DeleteChequeRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteChequeRequest._();
  @$core.override
  DeleteChequeRequest createEmptyInstance() => DeleteChequeRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteChequeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteChequeRequest>(DeleteChequeRequest.$_createMessage);
  static DeleteChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

/// UTXO Coin Control metadata
class UTXOMetadata extends $pb.GeneratedMessage {
  factory UTXOMetadata({
    $core.String? outpoint,
    $core.bool? isFrozen_2,
    $core.String? label,
  }) {
    final result = UTXOMetadata._();
    if (outpoint != null) result.outpoint = outpoint;
    if (isFrozen_2 != null) result.isFrozen_2 = isFrozen_2;
    if (label != null) result.label = label;
    return result;
  }

  UTXOMetadata._();

  factory UTXOMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UTXOMetadata()..mergeFromBuffer(data, registry);
  factory UTXOMetadata.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UTXOMetadata()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UTXOMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: UTXOMetadata.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOMetadata copyWith(void Function(UTXOMetadata) updates) =>
      super.copyWith((message) => updates(message as UTXOMetadata)) as UTXOMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UTXOMetadata() / UTXOMetadata.new instead')
  static UTXOMetadata create() => UTXOMetadata._();
  static $pb.GeneratedMessage $_createMessage() => UTXOMetadata._();
  @$core.override
  UTXOMetadata createEmptyInstance() => UTXOMetadata._();
  @$core.pragma('dart2js:noInline')
  static UTXOMetadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOMetadata>(UTXOMetadata.$_createMessage);
  static UTXOMetadata? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set outpoint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutpoint() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFrozen_2 => $_getBF(1);
  @$pb.TagNumber(2)
  set isFrozen_2($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFrozen_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFrozen_2() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);
}

class SetUTXOMetadataRequest extends $pb.GeneratedMessage {
  factory SetUTXOMetadataRequest({
    $core.String? outpoint,
    $core.bool? isFrozen_2,
    $core.String? label,
  }) {
    final result = SetUTXOMetadataRequest._();
    if (outpoint != null) result.outpoint = outpoint;
    if (isFrozen_2 != null) result.isFrozen_2 = isFrozen_2;
    if (label != null) result.label = label;
    return result;
  }

  SetUTXOMetadataRequest._();

  factory SetUTXOMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetUTXOMetadataRequest()..mergeFromBuffer(data, registry);
  factory SetUTXOMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetUTXOMetadataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetUTXOMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SetUTXOMetadataRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUTXOMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUTXOMetadataRequest copyWith(void Function(SetUTXOMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as SetUTXOMetadataRequest)) as SetUTXOMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetUTXOMetadataRequest() / SetUTXOMetadataRequest.new instead')
  static SetUTXOMetadataRequest create() => SetUTXOMetadataRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetUTXOMetadataRequest._();
  @$core.override
  SetUTXOMetadataRequest createEmptyInstance() => SetUTXOMetadataRequest._();
  @$core.pragma('dart2js:noInline')
  static SetUTXOMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetUTXOMetadataRequest>(SetUTXOMetadataRequest.$_createMessage);
  static SetUTXOMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set outpoint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutpoint() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFrozen_2 => $_getBF(1);
  @$pb.TagNumber(2)
  set isFrozen_2($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFrozen_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFrozen_2() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);
}

class GetUTXOMetadataRequest extends $pb.GeneratedMessage {
  factory GetUTXOMetadataRequest({
    $core.Iterable<$core.String>? outpoints,
  }) {
    final result = GetUTXOMetadataRequest._();
    if (outpoints != null) result.outpoints.addAll(outpoints);
    return result;
  }

  GetUTXOMetadataRequest._();

  factory GetUTXOMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXOMetadataRequest()..mergeFromBuffer(data, registry);
  factory GetUTXOMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXOMetadataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXOMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetUTXOMetadataRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'outpoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataRequest copyWith(void Function(GetUTXOMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as GetUTXOMetadataRequest)) as GetUTXOMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUTXOMetadataRequest() / GetUTXOMetadataRequest.new instead')
  static GetUTXOMetadataRequest create() => GetUTXOMetadataRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetUTXOMetadataRequest._();
  @$core.override
  GetUTXOMetadataRequest createEmptyInstance() => GetUTXOMetadataRequest._();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataRequest>(GetUTXOMetadataRequest.$_createMessage);
  static GetUTXOMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get outpoints => $_getList(0);
}

class GetUTXOMetadataResponse extends $pb.GeneratedMessage {
  factory GetUTXOMetadataResponse({
    $core.Iterable<$core.MapEntry<$core.String, UTXOMetadata>>? metadata,
  }) {
    final result = GetUTXOMetadataResponse._();
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  GetUTXOMetadataResponse._();

  factory GetUTXOMetadataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXOMetadataResponse()..mergeFromBuffer(data, registry);
  factory GetUTXOMetadataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXOMetadataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXOMetadataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetUTXOMetadataResponse.$_createMessage)
    ..m<$core.String, UTXOMetadata>(1, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'GetUTXOMetadataResponse.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: UTXOMetadata.$_createMessage,
        valueDefaultOrMaker: UTXOMetadata.getDefault,
        packageName: const $pb.PackageName('wallet.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataResponse copyWith(void Function(GetUTXOMetadataResponse) updates) =>
      super.copyWith((message) => updates(message as GetUTXOMetadataResponse)) as GetUTXOMetadataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUTXOMetadataResponse() / GetUTXOMetadataResponse.new instead')
  static GetUTXOMetadataResponse create() => GetUTXOMetadataResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetUTXOMetadataResponse._();
  @$core.override
  GetUTXOMetadataResponse createEmptyInstance() => GetUTXOMetadataResponse._();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataResponse>(GetUTXOMetadataResponse.$_createMessage);
  static GetUTXOMetadataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, UTXOMetadata> get metadata => $_getMap(0);
}

class SetCoinSelectionStrategyRequest extends $pb.GeneratedMessage {
  factory SetCoinSelectionStrategyRequest({
    CoinSelectionStrategy? strategy,
  }) {
    final result = SetCoinSelectionStrategyRequest._();
    if (strategy != null) result.strategy = strategy;
    return result;
  }

  SetCoinSelectionStrategyRequest._();

  factory SetCoinSelectionStrategyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoinSelectionStrategyRequest()..mergeFromBuffer(data, registry);
  factory SetCoinSelectionStrategyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoinSelectionStrategyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetCoinSelectionStrategyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SetCoinSelectionStrategyRequest.$_createMessage)
    ..aE<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy', enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoinSelectionStrategyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoinSelectionStrategyRequest copyWith(void Function(SetCoinSelectionStrategyRequest) updates) =>
      super.copyWith((message) => updates(message as SetCoinSelectionStrategyRequest))
          as SetCoinSelectionStrategyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetCoinSelectionStrategyRequest() / SetCoinSelectionStrategyRequest.new instead')
  static SetCoinSelectionStrategyRequest create() => SetCoinSelectionStrategyRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetCoinSelectionStrategyRequest._();
  @$core.override
  SetCoinSelectionStrategyRequest createEmptyInstance() => SetCoinSelectionStrategyRequest._();
  @$core.pragma('dart2js:noInline')
  static SetCoinSelectionStrategyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetCoinSelectionStrategyRequest>(
          SetCoinSelectionStrategyRequest.$_createMessage);
  static SetCoinSelectionStrategyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CoinSelectionStrategy get strategy => $_getN(0);
  @$pb.TagNumber(1)
  set strategy(CoinSelectionStrategy value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStrategy() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategy() => $_clearField(1);
}

class GetCoinSelectionStrategyResponse extends $pb.GeneratedMessage {
  factory GetCoinSelectionStrategyResponse({
    CoinSelectionStrategy? strategy,
  }) {
    final result = GetCoinSelectionStrategyResponse._();
    if (strategy != null) result.strategy = strategy;
    return result;
  }

  GetCoinSelectionStrategyResponse._();

  factory GetCoinSelectionStrategyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinSelectionStrategyResponse()..mergeFromBuffer(data, registry);
  factory GetCoinSelectionStrategyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinSelectionStrategyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinSelectionStrategyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetCoinSelectionStrategyResponse.$_createMessage)
    ..aE<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy', enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinSelectionStrategyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinSelectionStrategyResponse copyWith(void Function(GetCoinSelectionStrategyResponse) updates) =>
      super.copyWith((message) => updates(message as GetCoinSelectionStrategyResponse))
          as GetCoinSelectionStrategyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinSelectionStrategyResponse() / GetCoinSelectionStrategyResponse.new instead')
  static GetCoinSelectionStrategyResponse create() => GetCoinSelectionStrategyResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinSelectionStrategyResponse._();
  @$core.override
  GetCoinSelectionStrategyResponse createEmptyInstance() => GetCoinSelectionStrategyResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCoinSelectionStrategyResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinSelectionStrategyResponse>(
          GetCoinSelectionStrategyResponse.$_createMessage);
  static GetCoinSelectionStrategyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CoinSelectionStrategy get strategy => $_getN(0);
  @$pb.TagNumber(1)
  set strategy(CoinSelectionStrategy value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStrategy() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategy() => $_clearField(1);
}

/// Transaction Details - enriched transaction data with resolved inputs
class GetTransactionDetailsRequest extends $pb.GeneratedMessage {
  factory GetTransactionDetailsRequest({
    $core.String? txid,
  }) {
    final result = GetTransactionDetailsRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionDetailsRequest._();

  factory GetTransactionDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetTransactionDetailsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest copyWith(void Function(GetTransactionDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionDetailsRequest)) as GetTransactionDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionDetailsRequest() / GetTransactionDetailsRequest.new instead')
  static GetTransactionDetailsRequest create() => GetTransactionDetailsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionDetailsRequest._();
  @$core.override
  GetTransactionDetailsRequest createEmptyInstance() => GetTransactionDetailsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsRequest>(GetTransactionDetailsRequest.$_createMessage);
  static GetTransactionDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetTransactionDetailsResponse extends $pb.GeneratedMessage {
  factory GetTransactionDetailsResponse({
    $core.String? txid,
    $core.String? blockhash,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $core.int? version,
    $core.int? locktime,
    $core.int? sizeBytes,
    $core.int? vsizeVbytes,
    $core.int? weightWu,
    $fixnum.Int64? feeSats,
    $core.double? feeRateSatVb,
    $core.Iterable<TransactionInput>? inputs,
    $fixnum.Int64? totalInputSats,
    $core.Iterable<TransactionOutput>? outputs,
    $fixnum.Int64? totalOutputSats,
    $core.String? hex,
    $core.String? warningMessage,
  }) {
    final result = GetTransactionDetailsResponse._();
    if (txid != null) result.txid = txid;
    if (blockhash != null) result.blockhash = blockhash;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockTime != null) result.blockTime = blockTime;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (vsizeVbytes != null) result.vsizeVbytes = vsizeVbytes;
    if (weightWu != null) result.weightWu = weightWu;
    if (feeSats != null) result.feeSats = feeSats;
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    if (inputs != null) result.inputs.addAll(inputs);
    if (totalInputSats != null) result.totalInputSats = totalInputSats;
    if (outputs != null) result.outputs.addAll(outputs);
    if (totalOutputSats != null) result.totalOutputSats = totalOutputSats;
    if (hex != null) result.hex = hex;
    if (warningMessage != null) result.warningMessage = warningMessage;
    return result;
  }

  GetTransactionDetailsResponse._();

  factory GetTransactionDetailsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsResponse()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetTransactionDetailsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'blockhash')
    ..aI(3, _omitFieldNames ? '' : 'confirmations')
    ..aInt64(4, _omitFieldNames ? '' : 'blockTime')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aI(6, _omitFieldNames ? '' : 'locktime')
    ..aI(7, _omitFieldNames ? '' : 'sizeBytes')
    ..aI(8, _omitFieldNames ? '' : 'vsizeVbytes')
    ..aI(9, _omitFieldNames ? '' : 'weightWu')
    ..aInt64(10, _omitFieldNames ? '' : 'feeSats')
    ..aD(11, _omitFieldNames ? '' : 'feeRateSatVb')
    ..pPM<TransactionInput>(12, _omitFieldNames ? '' : 'inputs', subBuilder: TransactionInput.$_createMessage)
    ..aInt64(13, _omitFieldNames ? '' : 'totalInputSats')
    ..pPM<TransactionOutput>(14, _omitFieldNames ? '' : 'outputs', subBuilder: TransactionOutput.$_createMessage)
    ..aInt64(15, _omitFieldNames ? '' : 'totalOutputSats')
    ..aOS(16, _omitFieldNames ? '' : 'hex')
    ..aOS(17, _omitFieldNames ? '' : 'warningMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse copyWith(void Function(GetTransactionDetailsResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionDetailsResponse)) as GetTransactionDetailsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionDetailsResponse() / GetTransactionDetailsResponse.new instead')
  static GetTransactionDetailsResponse create() => GetTransactionDetailsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionDetailsResponse._();
  @$core.override
  GetTransactionDetailsResponse createEmptyInstance() => GetTransactionDetailsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsResponse>(GetTransactionDetailsResponse.$_createMessage);
  static GetTransactionDetailsResponse? _defaultInstance;

  /// Header info
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockhash => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockhash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockhash() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockhash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get blockTime => $_getI64(3);
  @$pb.TagNumber(4)
  set blockTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get locktime => $_getIZ(5);
  @$pb.TagNumber(6)
  set locktime($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLocktime() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocktime() => $_clearField(6);

  /// Size info
  @$pb.TagNumber(7)
  $core.int get sizeBytes => $_getIZ(6);
  @$pb.TagNumber(7)
  set sizeBytes($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSizeBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearSizeBytes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get vsizeVbytes => $_getIZ(7);
  @$pb.TagNumber(8)
  set vsizeVbytes($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVsizeVbytes() => $_has(7);
  @$pb.TagNumber(8)
  void clearVsizeVbytes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get weightWu => $_getIZ(8);
  @$pb.TagNumber(9)
  set weightWu($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWeightWu() => $_has(8);
  @$pb.TagNumber(9)
  void clearWeightWu() => $_clearField(9);

  /// Fee info (computed: sum(inputs) - sum(outputs))
  @$pb.TagNumber(10)
  $fixnum.Int64 get feeSats => $_getI64(9);
  @$pb.TagNumber(10)
  set feeSats($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFeeSats() => $_has(9);
  @$pb.TagNumber(10)
  void clearFeeSats() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get feeRateSatVb => $_getN(10);
  @$pb.TagNumber(11)
  set feeRateSatVb($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFeeRateSatVb() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeeRateSatVb() => $_clearField(11);

  /// Enriched inputs (backend resolves address/value from referenced tx)
  @$pb.TagNumber(12)
  $pb.PbList<TransactionInput> get inputs => $_getList(11);

  @$pb.TagNumber(13)
  $fixnum.Int64 get totalInputSats => $_getI64(12);
  @$pb.TagNumber(13)
  set totalInputSats($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTotalInputSats() => $_has(12);
  @$pb.TagNumber(13)
  void clearTotalInputSats() => $_clearField(13);

  /// Outputs
  @$pb.TagNumber(14)
  $pb.PbList<TransactionOutput> get outputs => $_getList(13);

  @$pb.TagNumber(15)
  $fixnum.Int64 get totalOutputSats => $_getI64(14);
  @$pb.TagNumber(15)
  set totalOutputSats($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasTotalOutputSats() => $_has(14);
  @$pb.TagNumber(15)
  void clearTotalOutputSats() => $_clearField(15);

  /// Raw hex for display
  @$pb.TagNumber(16)
  $core.String get hex => $_getSZ(15);
  @$pb.TagNumber(16)
  set hex($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasHex() => $_has(15);
  @$pb.TagNumber(16)
  void clearHex() => $_clearField(16);

  /// A backend warning for this transaction. Empty means no warning.
  @$pb.TagNumber(17)
  $core.String get warningMessage => $_getSZ(16);
  @$pb.TagNumber(17)
  set warningMessage($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasWarningMessage() => $_has(16);
  @$pb.TagNumber(17)
  void clearWarningMessage() => $_clearField(17);
}

class TransactionInput extends $pb.GeneratedMessage {
  factory TransactionInput({
    $core.int? index,
    $core.String? prevTxid,
    $core.int? prevVout,
    $core.String? address,
    $fixnum.Int64? valueSats,
    $core.String? scriptSigAsm,
    $core.String? scriptSigHex,
    $core.Iterable<$core.String>? witness,
    $fixnum.Int64? sequence,
    $core.bool? isCoinbase,
  }) {
    final result = TransactionInput._();
    if (index != null) result.index = index;
    if (prevTxid != null) result.prevTxid = prevTxid;
    if (prevVout != null) result.prevVout = prevVout;
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    if (scriptSigAsm != null) result.scriptSigAsm = scriptSigAsm;
    if (scriptSigHex != null) result.scriptSigHex = scriptSigHex;
    if (witness != null) result.witness.addAll(witness);
    if (sequence != null) result.sequence = sequence;
    if (isCoinbase != null) result.isCoinbase = isCoinbase;
    return result;
  }

  TransactionInput._();

  factory TransactionInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionInput()..mergeFromBuffer(data, registry);
  factory TransactionInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: TransactionInput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aOS(2, _omitFieldNames ? '' : 'prevTxid')
    ..aI(3, _omitFieldNames ? '' : 'prevVout')
    ..aOS(4, _omitFieldNames ? '' : 'address')
    ..aInt64(5, _omitFieldNames ? '' : 'valueSats')
    ..aOS(6, _omitFieldNames ? '' : 'scriptSigAsm')
    ..aOS(7, _omitFieldNames ? '' : 'scriptSigHex')
    ..pPS(8, _omitFieldNames ? '' : 'witness')
    ..aInt64(9, _omitFieldNames ? '' : 'sequence')
    ..aOB(10, _omitFieldNames ? '' : 'isCoinbase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionInput copyWith(void Function(TransactionInput) updates) =>
      super.copyWith((message) => updates(message as TransactionInput)) as TransactionInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionInput() / TransactionInput.new instead')
  static TransactionInput create() => TransactionInput._();
  static $pb.GeneratedMessage $_createMessage() => TransactionInput._();
  @$core.override
  TransactionInput createEmptyInstance() => TransactionInput._();
  @$core.pragma('dart2js:noInline')
  static TransactionInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionInput>(TransactionInput.$_createMessage);
  static TransactionInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevTxid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get prevVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set prevVout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevVout() => $_clearField(3);

  /// These require backend to fetch the referenced transaction
  @$pb.TagNumber(4)
  $core.String get address => $_getSZ(3);
  @$pb.TagNumber(4)
  set address($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get valueSats => $_getI64(4);
  @$pb.TagNumber(5)
  set valueSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValueSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueSats() => $_clearField(5);

  /// Script data
  @$pb.TagNumber(6)
  $core.String get scriptSigAsm => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptSigAsm($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptSigAsm() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptSigAsm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get scriptSigHex => $_getSZ(6);
  @$pb.TagNumber(7)
  set scriptSigHex($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasScriptSigHex() => $_has(6);
  @$pb.TagNumber(7)
  void clearScriptSigHex() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get witness => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get sequence => $_getI64(8);
  @$pb.TagNumber(9)
  set sequence($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSequence() => $_has(8);
  @$pb.TagNumber(9)
  void clearSequence() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isCoinbase => $_getBF(9);
  @$pb.TagNumber(10)
  set isCoinbase($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsCoinbase() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsCoinbase() => $_clearField(10);
}

class TransactionOutput extends $pb.GeneratedMessage {
  factory TransactionOutput({
    $core.int? index,
    $fixnum.Int64? valueSats,
    $core.String? address,
    $core.String? scriptType,
    $core.String? scriptPubkeyAsm,
    $core.String? scriptPubkeyHex,
    $core.bool? isChange,
    $core.bool? isMine,
  }) {
    final result = TransactionOutput._();
    if (index != null) result.index = index;
    if (valueSats != null) result.valueSats = valueSats;
    if (address != null) result.address = address;
    if (scriptType != null) result.scriptType = scriptType;
    if (scriptPubkeyAsm != null) result.scriptPubkeyAsm = scriptPubkeyAsm;
    if (scriptPubkeyHex != null) result.scriptPubkeyHex = scriptPubkeyHex;
    if (isChange != null) result.isChange = isChange;
    if (isMine != null) result.isMine = isMine;
    return result;
  }

  TransactionOutput._();

  factory TransactionOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionOutput()..mergeFromBuffer(data, registry);
  factory TransactionOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: TransactionOutput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'scriptType')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubkeyAsm')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..aOB(7, _omitFieldNames ? '' : 'isChange')
    ..aOB(8, _omitFieldNames ? '' : 'isMine')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput copyWith(void Function(TransactionOutput) updates) =>
      super.copyWith((message) => updates(message as TransactionOutput)) as TransactionOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionOutput() / TransactionOutput.new instead')
  static TransactionOutput create() => TransactionOutput._();
  static $pb.GeneratedMessage $_createMessage() => TransactionOutput._();
  @$core.override
  TransactionOutput createEmptyInstance() => TransactionOutput._();
  @$core.pragma('dart2js:noInline')
  static TransactionOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionOutput>(TransactionOutput.$_createMessage);
  static TransactionOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scriptType => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get scriptPubkeyAsm => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptPubkeyAsm($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScriptPubkeyAsm() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptPubkeyAsm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkeyHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkeyHex($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkeyHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkeyHex() => $_clearField(6);

  /// The output pays the wallet's own change chain.
  @$pb.TagNumber(7)
  $core.bool get isChange => $_getBF(6);
  @$pb.TagNumber(7)
  set isChange($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsChange() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsChange() => $_clearField(7);

  /// The wallet owns the output's address.
  @$pb.TagNumber(8)
  $core.bool get isMine => $_getBF(7);
  @$pb.TagNumber(8)
  set isMine($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsMine() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsMine() => $_clearField(8);
}

/// UTXO Distribution - for chart visualization
class GetUTXODistributionRequest extends $pb.GeneratedMessage {
  factory GetUTXODistributionRequest({
    $core.String? walletId,
    $core.int? maxBuckets,
  }) {
    final result = GetUTXODistributionRequest._();
    if (walletId != null) result.walletId = walletId;
    if (maxBuckets != null) result.maxBuckets = maxBuckets;
    return result;
  }

  GetUTXODistributionRequest._();

  factory GetUTXODistributionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXODistributionRequest()..mergeFromBuffer(data, registry);
  factory GetUTXODistributionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXODistributionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXODistributionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetUTXODistributionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'maxBuckets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionRequest copyWith(void Function(GetUTXODistributionRequest) updates) =>
      super.copyWith((message) => updates(message as GetUTXODistributionRequest)) as GetUTXODistributionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUTXODistributionRequest() / GetUTXODistributionRequest.new instead')
  static GetUTXODistributionRequest create() => GetUTXODistributionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetUTXODistributionRequest._();
  @$core.override
  GetUTXODistributionRequest createEmptyInstance() => GetUTXODistributionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionRequest>(GetUTXODistributionRequest.$_createMessage);
  static GetUTXODistributionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxBuckets => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxBuckets($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxBuckets() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxBuckets() => $_clearField(2);
}

class GetUTXODistributionResponse extends $pb.GeneratedMessage {
  factory GetUTXODistributionResponse({
    $core.Iterable<UTXOBucket>? buckets,
  }) {
    final result = GetUTXODistributionResponse._();
    if (buckets != null) result.buckets.addAll(buckets);
    return result;
  }

  GetUTXODistributionResponse._();

  factory GetUTXODistributionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXODistributionResponse()..mergeFromBuffer(data, registry);
  factory GetUTXODistributionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUTXODistributionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXODistributionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: GetUTXODistributionResponse.$_createMessage)
    ..pPM<UTXOBucket>(1, _omitFieldNames ? '' : 'buckets', subBuilder: UTXOBucket.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionResponse copyWith(void Function(GetUTXODistributionResponse) updates) =>
      super.copyWith((message) => updates(message as GetUTXODistributionResponse)) as GetUTXODistributionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUTXODistributionResponse() / GetUTXODistributionResponse.new instead')
  static GetUTXODistributionResponse create() => GetUTXODistributionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetUTXODistributionResponse._();
  @$core.override
  GetUTXODistributionResponse createEmptyInstance() => GetUTXODistributionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionResponse>(GetUTXODistributionResponse.$_createMessage);
  static GetUTXODistributionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UTXOBucket> get buckets => $_getList(0);
}

class UTXOBucket extends $pb.GeneratedMessage {
  factory UTXOBucket({
    $core.String? label,
    $fixnum.Int64? valueSats,
    $core.int? count,
    $core.Iterable<$core.String>? outpoints,
  }) {
    final result = UTXOBucket._();
    if (label != null) result.label = label;
    if (valueSats != null) result.valueSats = valueSats;
    if (count != null) result.count = count;
    if (outpoints != null) result.outpoints.addAll(outpoints);
    return result;
  }

  UTXOBucket._();

  factory UTXOBucket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UTXOBucket()..mergeFromBuffer(data, registry);
  factory UTXOBucket.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UTXOBucket()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UTXOBucket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: UTXOBucket.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..pPS(4, _omitFieldNames ? '' : 'outpoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOBucket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOBucket copyWith(void Function(UTXOBucket) updates) =>
      super.copyWith((message) => updates(message as UTXOBucket)) as UTXOBucket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UTXOBucket() / UTXOBucket.new instead')
  static UTXOBucket create() => UTXOBucket._();
  static $pb.GeneratedMessage $_createMessage() => UTXOBucket._();
  @$core.override
  UTXOBucket createEmptyInstance() => UTXOBucket._();
  @$core.pragma('dart2js:noInline')
  static UTXOBucket getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOBucket>(UTXOBucket.$_createMessage);
  static UTXOBucket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get outpoints => $_getList(3);
}

/// RBF - Replace-By-Fee (uses Bitcoin Core's automatic fee estimation)
class BumpFeeRequest extends $pb.GeneratedMessage {
  factory BumpFeeRequest({
    $core.String? txid,
  }) {
    final result = BumpFeeRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  BumpFeeRequest._();

  factory BumpFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromBuffer(data, registry);
  factory BumpFeeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: BumpFeeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) =>
      super.copyWith((message) => updates(message as BumpFeeRequest)) as BumpFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeRequest() / BumpFeeRequest.new instead')
  static BumpFeeRequest create() => BumpFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeRequest._();
  @$core.override
  BumpFeeRequest createEmptyInstance() => BumpFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(BumpFeeRequest.$_createMessage);
  static BumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class BumpFeeResponse extends $pb.GeneratedMessage {
  factory BumpFeeResponse({
    $core.String? txid,
    $core.double? originalFee,
    $core.double? newFee,
  }) {
    final result = BumpFeeResponse._();
    if (txid != null) result.txid = txid;
    if (originalFee != null) result.originalFee = originalFee;
    if (newFee != null) result.newFee = newFee;
    return result;
  }

  BumpFeeResponse._();

  factory BumpFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromBuffer(data, registry);
  factory BumpFeeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: BumpFeeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aD(2, _omitFieldNames ? '' : 'originalFee')
    ..aD(3, _omitFieldNames ? '' : 'newFee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) =>
      super.copyWith((message) => updates(message as BumpFeeResponse)) as BumpFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeResponse() / BumpFeeResponse.new instead')
  static BumpFeeResponse create() => BumpFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeResponse._();
  @$core.override
  BumpFeeResponse createEmptyInstance() => BumpFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(BumpFeeResponse.$_createMessage);
  static BumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get originalFee => $_getN(1);
  @$pb.TagNumber(2)
  set originalFee($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalFee() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get newFee => $_getN(2);
  @$pb.TagNumber(3)
  set newFee($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFee() => $_clearField(3);
}

/// Coin Selection - Select UTXOs for a transaction
class SelectCoinsRequest extends $pb.GeneratedMessage {
  factory SelectCoinsRequest({
    $core.String? walletId,
    $fixnum.Int64? targetSats,
    $fixnum.Int64? feeSatsPerVbyte,
    $core.int? numOutputs,
    CoinSelectionStrategy? strategy,
    $core.Iterable<$core.String>? frozenOutpoints,
    $core.Iterable<$core.String>? requiredOutpoints,
  }) {
    final result = SelectCoinsRequest._();
    if (walletId != null) result.walletId = walletId;
    if (targetSats != null) result.targetSats = targetSats;
    if (feeSatsPerVbyte != null) result.feeSatsPerVbyte = feeSatsPerVbyte;
    if (numOutputs != null) result.numOutputs = numOutputs;
    if (strategy != null) result.strategy = strategy;
    if (frozenOutpoints != null) result.frozenOutpoints.addAll(frozenOutpoints);
    if (requiredOutpoints != null) result.requiredOutpoints.addAll(requiredOutpoints);
    return result;
  }

  SelectCoinsRequest._();

  factory SelectCoinsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectCoinsRequest()..mergeFromBuffer(data, registry);
  factory SelectCoinsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectCoinsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SelectCoinsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SelectCoinsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'targetSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSatsPerVbyte')
    ..aI(4, _omitFieldNames ? '' : 'numOutputs')
    ..aE<CoinSelectionStrategy>(5, _omitFieldNames ? '' : 'strategy', enumValues: CoinSelectionStrategy.values)
    ..pPS(6, _omitFieldNames ? '' : 'frozenOutpoints')
    ..pPS(7, _omitFieldNames ? '' : 'requiredOutpoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsRequest copyWith(void Function(SelectCoinsRequest) updates) =>
      super.copyWith((message) => updates(message as SelectCoinsRequest)) as SelectCoinsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SelectCoinsRequest() / SelectCoinsRequest.new instead')
  static SelectCoinsRequest create() => SelectCoinsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SelectCoinsRequest._();
  @$core.override
  SelectCoinsRequest createEmptyInstance() => SelectCoinsRequest._();
  @$core.pragma('dart2js:noInline')
  static SelectCoinsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectCoinsRequest>(SelectCoinsRequest.$_createMessage);
  static SelectCoinsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get targetSats => $_getI64(1);
  @$pb.TagNumber(2)
  set targetSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatsPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatsPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSatsPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatsPerVbyte() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get numOutputs => $_getIZ(3);
  @$pb.TagNumber(4)
  set numOutputs($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumOutputs() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumOutputs() => $_clearField(4);

  @$pb.TagNumber(5)
  CoinSelectionStrategy get strategy => $_getN(4);
  @$pb.TagNumber(5)
  set strategy(CoinSelectionStrategy value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStrategy() => $_has(4);
  @$pb.TagNumber(5)
  void clearStrategy() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get frozenOutpoints => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get requiredOutpoints => $_getList(6);
}

class SelectCoinsResponse extends $pb.GeneratedMessage {
  factory SelectCoinsResponse({
    $core.Iterable<UnspentOutput>? selectedUtxos,
    $fixnum.Int64? totalInputSats,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? changeSats,
  }) {
    final result = SelectCoinsResponse._();
    if (selectedUtxos != null) result.selectedUtxos.addAll(selectedUtxos);
    if (totalInputSats != null) result.totalInputSats = totalInputSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (changeSats != null) result.changeSats = changeSats;
    return result;
  }

  SelectCoinsResponse._();

  factory SelectCoinsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectCoinsResponse()..mergeFromBuffer(data, registry);
  factory SelectCoinsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectCoinsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SelectCoinsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: SelectCoinsResponse.$_createMessage)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'selectedUtxos', subBuilder: UnspentOutput.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'totalInputSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'changeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsResponse copyWith(void Function(SelectCoinsResponse) updates) =>
      super.copyWith((message) => updates(message as SelectCoinsResponse)) as SelectCoinsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SelectCoinsResponse() / SelectCoinsResponse.new instead')
  static SelectCoinsResponse create() => SelectCoinsResponse._();
  static $pb.GeneratedMessage $_createMessage() => SelectCoinsResponse._();
  @$core.override
  SelectCoinsResponse createEmptyInstance() => SelectCoinsResponse._();
  @$core.pragma('dart2js:noInline')
  static SelectCoinsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectCoinsResponse>(SelectCoinsResponse.$_createMessage);
  static SelectCoinsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnspentOutput> get selectedUtxos => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalInputSats => $_getI64(1);
  @$pb.TagNumber(2)
  set totalInputSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalInputSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalInputSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get changeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set changeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChangeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearChangeSats() => $_clearField(4);
}

/// Backup / Restore messages
class CreateBackupResponse extends $pb.GeneratedMessage {
  factory CreateBackupResponse({
    $core.List<$core.int>? backupData,
    $core.String? suggestedFilename,
  }) {
    final result = CreateBackupResponse._();
    if (backupData != null) result.backupData = backupData;
    if (suggestedFilename != null) result.suggestedFilename = suggestedFilename;
    return result;
  }

  CreateBackupResponse._();

  factory CreateBackupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBackupResponse()..mergeFromBuffer(data, registry);
  factory CreateBackupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBackupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBackupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: CreateBackupResponse.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'suggestedFilename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBackupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBackupResponse copyWith(void Function(CreateBackupResponse) updates) =>
      super.copyWith((message) => updates(message as CreateBackupResponse)) as CreateBackupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateBackupResponse() / CreateBackupResponse.new instead')
  static CreateBackupResponse create() => CreateBackupResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateBackupResponse._();
  @$core.override
  CreateBackupResponse createEmptyInstance() => CreateBackupResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateBackupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBackupResponse>(CreateBackupResponse.$_createMessage);
  static CreateBackupResponse? _defaultInstance;

  /// ZIP archive bytes containing wallet.json, multisig data, transactions
  @$pb.TagNumber(1)
  $core.List<$core.int> get backupData => $_getN(0);
  @$pb.TagNumber(1)
  set backupData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBackupData() => $_has(0);
  @$pb.TagNumber(1)
  void clearBackupData() => $_clearField(1);

  /// Suggested filename
  @$pb.TagNumber(2)
  $core.String get suggestedFilename => $_getSZ(1);
  @$pb.TagNumber(2)
  set suggestedFilename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuggestedFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuggestedFilename() => $_clearField(2);
}

class RestoreBackupRequest extends $pb.GeneratedMessage {
  factory RestoreBackupRequest({
    $core.List<$core.int>? backupData,
    $core.String? filename,
  }) {
    final result = RestoreBackupRequest._();
    if (backupData != null) result.backupData = backupData;
    if (filename != null) result.filename = filename;
    return result;
  }

  RestoreBackupRequest._();

  factory RestoreBackupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreBackupRequest()..mergeFromBuffer(data, registry);
  factory RestoreBackupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreBackupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreBackupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: RestoreBackupRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreBackupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreBackupRequest copyWith(void Function(RestoreBackupRequest) updates) =>
      super.copyWith((message) => updates(message as RestoreBackupRequest)) as RestoreBackupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreBackupRequest() / RestoreBackupRequest.new instead')
  static RestoreBackupRequest create() => RestoreBackupRequest._();
  static $pb.GeneratedMessage $_createMessage() => RestoreBackupRequest._();
  @$core.override
  RestoreBackupRequest createEmptyInstance() => RestoreBackupRequest._();
  @$core.pragma('dart2js:noInline')
  static RestoreBackupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreBackupRequest>(RestoreBackupRequest.$_createMessage);
  static RestoreBackupRequest? _defaultInstance;

  /// ZIP or JSON backup file bytes
  @$pb.TagNumber(1)
  $core.List<$core.int> get backupData => $_getN(0);
  @$pb.TagNumber(1)
  set backupData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBackupData() => $_has(0);
  @$pb.TagNumber(1)
  void clearBackupData() => $_clearField(1);

  /// Original filename (used to detect .json vs .zip)
  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);
}

class ValidateBackupRequest extends $pb.GeneratedMessage {
  factory ValidateBackupRequest({
    $core.List<$core.int>? backupData,
    $core.String? filename,
  }) {
    final result = ValidateBackupRequest._();
    if (backupData != null) result.backupData = backupData;
    if (filename != null) result.filename = filename;
    return result;
  }

  ValidateBackupRequest._();

  factory ValidateBackupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBackupRequest()..mergeFromBuffer(data, registry);
  factory ValidateBackupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBackupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBackupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ValidateBackupRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupRequest copyWith(void Function(ValidateBackupRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateBackupRequest)) as ValidateBackupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateBackupRequest() / ValidateBackupRequest.new instead')
  static ValidateBackupRequest create() => ValidateBackupRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateBackupRequest._();
  @$core.override
  ValidateBackupRequest createEmptyInstance() => ValidateBackupRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateBackupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBackupRequest>(ValidateBackupRequest.$_createMessage);
  static ValidateBackupRequest? _defaultInstance;

  /// ZIP or JSON backup file bytes
  @$pb.TagNumber(1)
  $core.List<$core.int> get backupData => $_getN(0);
  @$pb.TagNumber(1)
  set backupData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBackupData() => $_has(0);
  @$pb.TagNumber(1)
  void clearBackupData() => $_clearField(1);

  /// Original filename (used to detect .json vs .zip)
  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);
}

class ValidateBackupResponse extends $pb.GeneratedMessage {
  factory ValidateBackupResponse({
    $core.bool? valid,
    $core.String? errorMessage,
    $core.bool? hasWallet,
    $core.bool? hasMultisig,
    $core.bool? hasTransactions,
  }) {
    final result = ValidateBackupResponse._();
    if (valid != null) result.valid = valid;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (hasWallet != null) result.hasWallet = hasWallet;
    if (hasMultisig != null) result.hasMultisig = hasMultisig;
    if (hasTransactions != null) result.hasTransactions = hasTransactions;
    return result;
  }

  ValidateBackupResponse._();

  factory ValidateBackupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBackupResponse()..mergeFromBuffer(data, registry);
  factory ValidateBackupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBackupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBackupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: ValidateBackupResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOB(3, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(4, _omitFieldNames ? '' : 'hasMultisig')
    ..aOB(5, _omitFieldNames ? '' : 'hasTransactions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupResponse copyWith(void Function(ValidateBackupResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateBackupResponse)) as ValidateBackupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateBackupResponse() / ValidateBackupResponse.new instead')
  static ValidateBackupResponse create() => ValidateBackupResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateBackupResponse._();
  @$core.override
  ValidateBackupResponse createEmptyInstance() => ValidateBackupResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateBackupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBackupResponse>(ValidateBackupResponse.$_createMessage);
  static ValidateBackupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  /// What the backup contains
  @$pb.TagNumber(3)
  $core.bool get hasWallet => $_getBF(2);
  @$pb.TagNumber(3)
  set hasWallet($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasWallet() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasMultisig => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMultisig($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasMultisig() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMultisig() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasTransactions => $_getBF(4);
  @$pb.TagNumber(5)
  set hasTransactions($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHasTransactions() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasTransactions() => $_clearField(5);
}

class WalletServiceApi {
  final $pb.RpcClient _client;

  WalletServiceApi(this._client);

  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
      _client.invoke<SendTransactionResponse>(
          ctx, 'WalletService', 'SendTransaction', request, SendTransactionResponse());
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'WalletService', 'GetBalance', request, GetBalanceResponse());

  /// Problem: deriving nilly willy here is potentially problematic. There's no way of listing
  /// out unused addresses, so we risk crossing the sync gap.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'WalletService', 'GetNewAddress', request, GetNewAddressResponse());
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'WalletService', 'ListTransactions', request, ListTransactionsResponse());
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
      _client.invoke<ListUnspentResponse>(ctx, 'WalletService', 'ListUnspent', request, ListUnspentResponse());
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses(
          $pb.ClientContext? ctx, ListReceiveAddressesRequest request) =>
      _client.invoke<ListReceiveAddressesResponse>(
          ctx, 'WalletService', 'ListReceiveAddresses', request, ListReceiveAddressesResponse());
  $async.Future<ListSidechainDepositsResponse> listSidechainDeposits(
          $pb.ClientContext? ctx, ListSidechainDepositsRequest request) =>
      _client.invoke<ListSidechainDepositsResponse>(
          ctx, 'WalletService', 'ListSidechainDeposits', request, ListSidechainDepositsResponse());
  $async.Future<CreateSidechainDepositResponse> createSidechainDeposit(
          $pb.ClientContext? ctx, CreateSidechainDepositRequest request) =>
      _client.invoke<CreateSidechainDepositResponse>(
          ctx, 'WalletService', 'CreateSidechainDeposit', request, CreateSidechainDepositResponse());
  $async.Future<SignMessageResponse> signMessage($pb.ClientContext? ctx, SignMessageRequest request) =>
      _client.invoke<SignMessageResponse>(ctx, 'WalletService', 'SignMessage', request, SignMessageResponse());
  $async.Future<VerifyMessageResponse> verifyMessage($pb.ClientContext? ctx, VerifyMessageRequest request) =>
      _client.invoke<VerifyMessageResponse>(ctx, 'WalletService', 'VerifyMessage', request, VerifyMessageResponse());
  $async.Future<GetStatsResponse> getStats($pb.ClientContext? ctx, GetStatsRequest request) =>
      _client.invoke<GetStatsResponse>(ctx, 'WalletService', 'GetStats', request, GetStatsResponse());

  /// Wallet unlock/lock for cheque operations
  $async.Future<$2.Empty> unlockWallet($pb.ClientContext? ctx, UnlockWalletRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'UnlockWallet', request, $2.Empty());
  $async.Future<$2.Empty> lockWallet($pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'LockWallet', request, $2.Empty());
  $async.Future<$2.Empty> isWalletUnlocked($pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'IsWalletUnlocked', request, $2.Empty());

  /// Cheque operations
  $async.Future<CreateChequeResponse> createCheque($pb.ClientContext? ctx, CreateChequeRequest request) =>
      _client.invoke<CreateChequeResponse>(ctx, 'WalletService', 'CreateCheque', request, CreateChequeResponse());
  $async.Future<GetChequeResponse> getCheque($pb.ClientContext? ctx, GetChequeRequest request) =>
      _client.invoke<GetChequeResponse>(ctx, 'WalletService', 'GetCheque', request, GetChequeResponse());
  $async.Future<GetChequePrivateKeyResponse> getChequePrivateKey(
          $pb.ClientContext? ctx, GetChequePrivateKeyRequest request) =>
      _client.invoke<GetChequePrivateKeyResponse>(
          ctx, 'WalletService', 'GetChequePrivateKey', request, GetChequePrivateKeyResponse());
  $async.Future<ListChequesResponse> listCheques($pb.ClientContext? ctx, ListChequesRequest request) =>
      _client.invoke<ListChequesResponse>(ctx, 'WalletService', 'ListCheques', request, ListChequesResponse());
  $async.Future<CheckChequeFundingResponse> checkChequeFunding(
          $pb.ClientContext? ctx, CheckChequeFundingRequest request) =>
      _client.invoke<CheckChequeFundingResponse>(
          ctx, 'WalletService', 'CheckChequeFunding', request, CheckChequeFundingResponse());
  $async.Future<PreviewSweepResponse> previewSweep($pb.ClientContext? ctx, PreviewSweepRequest request) =>
      _client.invoke<PreviewSweepResponse>(ctx, 'WalletService', 'PreviewSweep', request, PreviewSweepResponse());
  $async.Future<SweepChequeResponse> sweepCheque($pb.ClientContext? ctx, SweepChequeRequest request) =>
      _client.invoke<SweepChequeResponse>(ctx, 'WalletService', 'SweepCheque', request, SweepChequeResponse());
  $async.Future<$2.Empty> deleteCheque($pb.ClientContext? ctx, DeleteChequeRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'DeleteCheque', request, $2.Empty());

  /// UTXO Coin Control
  $async.Future<$2.Empty> setUTXOMetadata($pb.ClientContext? ctx, SetUTXOMetadataRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'SetUTXOMetadata', request, $2.Empty());
  $async.Future<GetUTXOMetadataResponse> getUTXOMetadata($pb.ClientContext? ctx, GetUTXOMetadataRequest request) =>
      _client.invoke<GetUTXOMetadataResponse>(
          ctx, 'WalletService', 'GetUTXOMetadata', request, GetUTXOMetadataResponse());

  /// Coin Selection Preferences
  $async.Future<$2.Empty> setCoinSelectionStrategy($pb.ClientContext? ctx, SetCoinSelectionStrategyRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'SetCoinSelectionStrategy', request, $2.Empty());
  $async.Future<GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<GetCoinSelectionStrategyResponse>(
          ctx, 'WalletService', 'GetCoinSelectionStrategy', request, GetCoinSelectionStrategyResponse());

  /// Transaction Details (enriched with input values/addresses)
  $async.Future<GetTransactionDetailsResponse> getTransactionDetails(
          $pb.ClientContext? ctx, GetTransactionDetailsRequest request) =>
      _client.invoke<GetTransactionDetailsResponse>(
          ctx, 'WalletService', 'GetTransactionDetails', request, GetTransactionDetailsResponse());

  /// UTXO Distribution (for chart visualization)
  $async.Future<GetUTXODistributionResponse> getUTXODistribution(
          $pb.ClientContext? ctx, GetUTXODistributionRequest request) =>
      _client.invoke<GetUTXODistributionResponse>(
          ctx, 'WalletService', 'GetUTXODistribution', request, GetUTXODistributionResponse());

  /// RBF - Replace-By-Fee for unconfirmed transactions
  $async.Future<BumpFeeResponse> bumpFee($pb.ClientContext? ctx, BumpFeeRequest request) =>
      _client.invoke<BumpFeeResponse>(ctx, 'WalletService', 'BumpFee', request, BumpFeeResponse());

  /// Coin Selection - Select UTXOs for a transaction
  $async.Future<SelectCoinsResponse> selectCoins($pb.ClientContext? ctx, SelectCoinsRequest request) =>
      _client.invoke<SelectCoinsResponse>(ctx, 'WalletService', 'SelectCoins', request, SelectCoinsResponse());

  /// Backup / Restore
  $async.Future<CreateBackupResponse> createBackup($pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<CreateBackupResponse>(ctx, 'WalletService', 'CreateBackup', request, CreateBackupResponse());
  $async.Future<$2.Empty> restoreBackup($pb.ClientContext? ctx, RestoreBackupRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'RestoreBackup', request, $2.Empty());
  $async.Future<ValidateBackupResponse> validateBackup($pb.ClientContext? ctx, ValidateBackupRequest request) =>
      _client.invoke<ValidateBackupResponse>(ctx, 'WalletService', 'ValidateBackup', request, ValidateBackupResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
