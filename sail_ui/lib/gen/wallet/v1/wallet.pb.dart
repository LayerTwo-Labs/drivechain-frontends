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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import '../../bitwindowd/v1/bitwindowd.pb.dart' as $1;
import 'wallet.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'wallet.pbenum.dart';

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest({
    $core.String? walletId,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetBalanceRequest._();

  factory GetBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest copyWith(void Function(GetBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetBalanceRequest))
          as GetBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest create() => GetBalanceRequest._();
  @$core.override
  GetBalanceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalanceRequest>(create);
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
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressRequest))
          as GetNewAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  @$core.override
  GetNewAddressRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(create);
  static GetNewAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
    $core.int? index,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (index != null) result.index = index;
    return result;
  }

  GetNewAddressResponse._();

  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNewAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNewAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aI(2, _omitFieldNames ? '' : 'index', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse copyWith(
          void Function(GetNewAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressResponse))
          as GetNewAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  @$core.override
  GetNewAddressResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(
          void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest))
          as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListUnspentRequest._();

  factory ListUnspentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUnspentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUnspentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) =>
      super.copyWith((message) => updates(message as ListUnspentRequest))
          as ListUnspentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest create() => ListUnspentRequest._();
  @$core.override
  ListUnspentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListReceiveAddressesRequest._();

  factory ListReceiveAddressesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListReceiveAddressesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest copyWith(
          void Function(ListReceiveAddressesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListReceiveAddressesRequest))
          as ListReceiveAddressesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest create() =>
      ListReceiveAddressesRequest._();
  @$core.override
  ListReceiveAddressesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesRequest>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetStatsRequest._();

  factory GetStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatsRequest))
          as GetStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsRequest create() => GetStatsRequest._();
  @$core.override
  GetStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(create);
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
    final result = create();
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
      create()..mergeFromBuffer(data, registry);
  factory SendTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'SendTransactionRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OU6,
        packageName: const $pb.PackageName('wallet.v1'))
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'fixedFeeSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'opReturnMessage')
    ..aOS(6, _omitFieldNames ? '' : 'label')
    ..pPM<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs',
        subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest copyWith(
          void Function(SendTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SendTransactionRequest))
          as SendTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest create() => SendTransactionRequest._();
  @$core.override
  SendTransactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest>(create);
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
    final result = create();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendTransactionResponse._();

  factory SendTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse copyWith(
          void Function(SendTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SendTransactionResponse))
          as SendTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse create() => SendTransactionResponse._();
  @$core.override
  SendTransactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionResponse>(create);
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
  }) {
    final result = create();
    if (confirmedSatoshi != null) result.confirmedSatoshi = confirmedSatoshi;
    if (pendingSatoshi != null) result.pendingSatoshi = pendingSatoshi;
    return result;
  }

  GetBalanceResponse._();

  factory GetBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'confirmedSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'pendingSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse copyWith(void Function(GetBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetBalanceResponse))
          as GetBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse create() => GetBalanceResponse._();
  @$core.override
  GetBalanceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalanceResponse>(create);
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
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<WalletTransaction>? transactions,
  }) {
    final result = create();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<WalletTransaction>(1, _omitFieldNames ? '' : 'transactions',
        subBuilder: WalletTransaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(
          void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse))
          as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(create);
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
  }) {
    final result = create();
    if (output != null) result.output = output;
    if (address != null) result.address = address;
    if (label != null) result.label = label;
    if (valueSats != null) result.valueSats = valueSats;
    if (isChange != null) result.isChange = isChange;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (denialInfo != null) result.denialInfo = denialInfo;
    return result;
  }

  UnspentOutput._();

  factory UnspentOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnspentOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnspentOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'output')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'valueSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'receivedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.DenialInfo>(7, _omitFieldNames ? '' : 'denialInfo',
        subBuilder: $1.DenialInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) =>
      super.copyWith((message) => updates(message as UnspentOutput))
          as UnspentOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnspentOutput create() => UnspentOutput._();
  @$core.override
  UnspentOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(create);
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
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? utxos,
  }) {
    final result = create();
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  ListUnspentResponse._();

  factory ListUnspentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUnspentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUnspentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'utxos',
        subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) =>
      super.copyWith((message) => updates(message as ListUnspentResponse))
          as ListUnspentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse create() => ListUnspentResponse._();
  @$core.override
  ListUnspentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(create);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnspentOutput> get utxos => $_getList(0);
}

class ListReceiveAddressesResponse extends $pb.GeneratedMessage {
  factory ListReceiveAddressesResponse({
    $core.Iterable<ReceiveAddress>? addresses,
  }) {
    final result = create();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  ListReceiveAddressesResponse._();

  factory ListReceiveAddressesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListReceiveAddressesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<ReceiveAddress>(1, _omitFieldNames ? '' : 'addresses',
        subBuilder: ReceiveAddress.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse copyWith(
          void Function(ListReceiveAddressesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListReceiveAddressesResponse))
          as ListReceiveAddressesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse create() =>
      ListReceiveAddressesResponse._();
  @$core.override
  ListReceiveAddressesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesResponse>(create);
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
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (label != null) result.label = label;
    if (currentBalanceSat != null) result.currentBalanceSat = currentBalanceSat;
    if (isChange != null) result.isChange = isChange;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    return result;
  }

  ReceiveAddress._();

  factory ReceiveAddress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReceiveAddress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveAddress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'currentBalanceSat', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastUsedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress copyWith(void Function(ReceiveAddress) updates) =>
      super.copyWith((message) => updates(message as ReceiveAddress))
          as ReceiveAddress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveAddress create() => ReceiveAddress._();
  @$core.override
  ReceiveAddress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReceiveAddress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveAddress>(create);
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
}

class Confirmation extends $pb.GeneratedMessage {
  factory Confirmation({
    $core.int? height,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (height != null) result.height = height;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  Confirmation._();

  factory Confirmation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Confirmation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Confirmation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Confirmation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Confirmation copyWith(void Function(Confirmation) updates) =>
      super.copyWith((message) => updates(message as Confirmation))
          as Confirmation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Confirmation create() => Confirmation._();
  @$core.override
  Confirmation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Confirmation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Confirmation>(create);
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
  }) {
    final result = create();
    if (txid != null) result.txid = txid;
    if (feeSats != null) result.feeSats = feeSats;
    if (receivedSatoshi != null) result.receivedSatoshi = receivedSatoshi;
    if (sentSatoshi != null) result.sentSatoshi = sentSatoshi;
    if (address != null) result.address = address;
    if (addressLabel != null) result.addressLabel = addressLabel;
    if (note != null) result.note = note;
    if (confirmationTime != null) result.confirmationTime = confirmationTime;
    return result;
  }

  WalletTransaction._();

  factory WalletTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WalletTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WalletTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'receivedSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'sentSatoshi', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'address')
    ..aOS(6, _omitFieldNames ? '' : 'addressLabel')
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..aOM<Confirmation>(8, _omitFieldNames ? '' : 'confirmationTime',
        subBuilder: Confirmation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletTransaction copyWith(void Function(WalletTransaction) updates) =>
      super.copyWith((message) => updates(message as WalletTransaction))
          as WalletTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletTransaction create() => WalletTransaction._();
  @$core.override
  WalletTransaction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WalletTransaction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WalletTransaction>(create);
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
}

class ListSidechainDepositsRequest extends $pb.GeneratedMessage {
  factory ListSidechainDepositsRequest({
    $core.String? walletId,
    $core.int? slot,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (slot != null) result.slot = slot;
    return result;
  }

  ListSidechainDepositsRequest._();

  factory ListSidechainDepositsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSidechainDepositsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'slot')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest copyWith(
          void Function(ListSidechainDepositsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListSidechainDepositsRequest))
          as ListSidechainDepositsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest create() =>
      ListSidechainDepositsRequest._();
  @$core.override
  ListSidechainDepositsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsRequest>(create);
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

class ListSidechainDepositsResponse_SidechainDeposit
    extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse_SidechainDeposit({
    $core.String? txid,
    $fixnum.Int64? amount,
    $fixnum.Int64? fee,
    $core.int? confirmations,
  }) {
    final result = create();
    if (txid != null) result.txid = txid;
    if (amount != null) result.amount = amount;
    if (fee != null) result.fee = fee;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  ListSidechainDepositsResponse_SidechainDeposit._();

  factory ListSidechainDepositsResponse_SidechainDeposit.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsResponse_SidechainDeposit.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSidechainDepositsResponse.SidechainDeposit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'fee')
    ..aI(4, _omitFieldNames ? '' : 'confirmations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse_SidechainDeposit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse_SidechainDeposit copyWith(
          void Function(ListSidechainDepositsResponse_SidechainDeposit)
              updates) =>
      super.copyWith((message) => updates(
              message as ListSidechainDepositsResponse_SidechainDeposit))
          as ListSidechainDepositsResponse_SidechainDeposit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse_SidechainDeposit create() =>
      ListSidechainDepositsResponse_SidechainDeposit._();
  @$core.override
  ListSidechainDepositsResponse_SidechainDeposit createEmptyInstance() =>
      create();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse_SidechainDeposit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          ListSidechainDepositsResponse_SidechainDeposit>(create);
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
}

class ListSidechainDepositsResponse extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse({
    $core.Iterable<ListSidechainDepositsResponse_SidechainDeposit>? deposits,
  }) {
    final result = create();
    if (deposits != null) result.deposits.addAll(deposits);
    return result;
  }

  ListSidechainDepositsResponse._();

  factory ListSidechainDepositsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSidechainDepositsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<ListSidechainDepositsResponse_SidechainDeposit>(
        1, _omitFieldNames ? '' : 'deposits',
        subBuilder: ListSidechainDepositsResponse_SidechainDeposit.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse copyWith(
          void Function(ListSidechainDepositsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListSidechainDepositsResponse))
          as ListSidechainDepositsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse create() =>
      ListSidechainDepositsResponse._();
  @$core.override
  ListSidechainDepositsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse>(create);
  static ListSidechainDepositsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ListSidechainDepositsResponse_SidechainDeposit> get deposits =>
      $_getList(0);
}

class CreateSidechainDepositRequest extends $pb.GeneratedMessage {
  factory CreateSidechainDepositRequest({
    $core.String? walletId,
    $fixnum.Int64? slot,
    $core.String? destination,
    $core.double? amount,
    $core.double? fee,
  }) {
    final result = create();
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
      create()..mergeFromBuffer(data, registry);
  factory CreateSidechainDepositRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSidechainDepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'slot')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aD(4, _omitFieldNames ? '' : 'amount')
    ..aD(5, _omitFieldNames ? '' : 'fee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositRequest copyWith(
          void Function(CreateSidechainDepositRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateSidechainDepositRequest))
          as CreateSidechainDepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositRequest create() =>
      CreateSidechainDepositRequest._();
  @$core.override
  CreateSidechainDepositRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositRequest>(create);
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
    final result = create();
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateSidechainDepositResponse._();

  factory CreateSidechainDepositResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateSidechainDepositResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSidechainDepositResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSidechainDepositResponse copyWith(
          void Function(CreateSidechainDepositResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateSidechainDepositResponse))
          as CreateSidechainDepositResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositResponse create() =>
      CreateSidechainDepositResponse._();
  @$core.override
  CreateSidechainDepositResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositResponse>(create);
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
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (message != null) result.message = message;
    return result;
  }

  SignMessageRequest._();

  factory SignMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageRequest copyWith(void Function(SignMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SignMessageRequest))
          as SignMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignMessageRequest create() => SignMessageRequest._();
  @$core.override
  SignMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignMessageRequest>(create);
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
}

class SignMessageResponse extends $pb.GeneratedMessage {
  factory SignMessageResponse({
    $core.String? signature,
  }) {
    final result = create();
    if (signature != null) result.signature = signature;
    return result;
  }

  SignMessageResponse._();

  factory SignMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignMessageResponse copyWith(void Function(SignMessageResponse) updates) =>
      super.copyWith((message) => updates(message as SignMessageResponse))
          as SignMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignMessageResponse create() => SignMessageResponse._();
  @$core.override
  SignMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignMessageResponse>(create);
  static SignMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);
}

class VerifyMessageRequest extends $pb.GeneratedMessage {
  factory VerifyMessageRequest({
    $core.String? walletId,
    $core.String? message,
    $core.String? signature,
    $core.String? publicKey,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (message != null) result.message = message;
    if (signature != null) result.signature = signature;
    if (publicKey != null) result.publicKey = publicKey;
    return result;
  }

  VerifyMessageRequest._();

  factory VerifyMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'signature')
    ..aOS(4, _omitFieldNames ? '' : 'publicKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageRequest copyWith(void Function(VerifyMessageRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyMessageRequest))
          as VerifyMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyMessageRequest create() => VerifyMessageRequest._();
  @$core.override
  VerifyMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyMessageRequest>(create);
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
}

class VerifyMessageResponse extends $pb.GeneratedMessage {
  factory VerifyMessageResponse({
    $core.bool? valid,
  }) {
    final result = create();
    if (valid != null) result.valid = valid;
    return result;
  }

  VerifyMessageResponse._();

  factory VerifyMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMessageResponse copyWith(
          void Function(VerifyMessageResponse) updates) =>
      super.copyWith((message) => updates(message as VerifyMessageResponse))
          as VerifyMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyMessageResponse create() => VerifyMessageResponse._();
  @$core.override
  VerifyMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyMessageResponse>(create);
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
  }) {
    final result = create();
    if (utxosCurrent != null) result.utxosCurrent = utxosCurrent;
    if (utxosUniqueAddresses != null)
      result.utxosUniqueAddresses = utxosUniqueAddresses;
    if (sidechainDepositVolume != null)
      result.sidechainDepositVolume = sidechainDepositVolume;
    if (sidechainDepositVolumeLast30Days != null)
      result.sidechainDepositVolumeLast30Days =
          sidechainDepositVolumeLast30Days;
    if (transactionCountTotal != null)
      result.transactionCountTotal = transactionCountTotal;
    if (transactionCountSinceMonth != null)
      result.transactionCountSinceMonth = transactionCountSinceMonth;
    return result;
  }

  GetStatsResponse._();

  factory GetStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'utxosCurrent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'utxosUniqueAddresses', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'sidechainDepositVolume')
    ..aInt64(4, _omitFieldNames ? '' : 'sidechainDepositVolumeLast30Days',
        protoName: 'sidechain_deposit_volume_last_30_days')
    ..aInt64(5, _omitFieldNames ? '' : 'transactionCountTotal')
    ..aInt64(6, _omitFieldNames ? '' : 'transactionCountSinceMonth')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse copyWith(void Function(GetStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatsResponse))
          as GetStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsResponse create() => GetStatsResponse._();
  @$core.override
  GetStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatsResponse>(create);
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
  set sidechainDepositVolumeLast30Days($fixnum.Int64 value) =>
      $_setInt64(3, value);
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
}

/// Wallet unlock/lock messages
class UnlockWalletRequest extends $pb.GeneratedMessage {
  factory UnlockWalletRequest({
    $core.String? password,
  }) {
    final result = create();
    if (password != null) result.password = password;
    return result;
  }

  UnlockWalletRequest._();

  factory UnlockWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlockWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlockWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest copyWith(void Function(UnlockWalletRequest) updates) =>
      super.copyWith((message) => updates(message as UnlockWalletRequest))
          as UnlockWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest create() => UnlockWalletRequest._();
  @$core.override
  UnlockWalletRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockWalletRequest>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (expectedAmountSats != null)
      result.expectedAmountSats = expectedAmountSats;
    return result;
  }

  CreateChequeRequest._();

  factory CreateChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeRequest copyWith(void Function(CreateChequeRequest) updates) =>
      super.copyWith((message) => updates(message as CreateChequeRequest))
          as CreateChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChequeRequest create() => CreateChequeRequest._();
  @$core.override
  CreateChequeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateChequeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChequeRequest>(create);
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
    final result = create();
    if (id != null) result.id = id;
    if (address != null) result.address = address;
    if (derivationIndex != null) result.derivationIndex = derivationIndex;
    return result;
  }

  CreateChequeResponse._();

  factory CreateChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aI(3, _omitFieldNames ? '' : 'derivationIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChequeResponse copyWith(void Function(CreateChequeResponse) updates) =>
      super.copyWith((message) => updates(message as CreateChequeResponse))
          as CreateChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChequeResponse create() => CreateChequeResponse._();
  @$core.override
  CreateChequeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateChequeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChequeResponse>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  GetChequeRequest._();

  factory GetChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeRequest copyWith(void Function(GetChequeRequest) updates) =>
      super.copyWith((message) => updates(message as GetChequeRequest))
          as GetChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequeRequest create() => GetChequeRequest._();
  @$core.override
  GetChequeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChequeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequeRequest>(create);
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
    final result = create();
    if (cheque != null) result.cheque = cheque;
    return result;
  }

  GetChequeResponse._();

  factory GetChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOM<Cheque>(1, _omitFieldNames ? '' : 'cheque', subBuilder: Cheque.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequeResponse copyWith(void Function(GetChequeResponse) updates) =>
      super.copyWith((message) => updates(message as GetChequeResponse))
          as GetChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequeResponse create() => GetChequeResponse._();
  @$core.override
  GetChequeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChequeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequeResponse>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  GetChequePrivateKeyRequest._();

  factory GetChequePrivateKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChequePrivateKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChequePrivateKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyRequest copyWith(
          void Function(GetChequePrivateKeyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetChequePrivateKeyRequest))
          as GetChequePrivateKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyRequest create() => GetChequePrivateKeyRequest._();
  @$core.override
  GetChequePrivateKeyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyRequest>(create);
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
    final result = create();
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    return result;
  }

  GetChequePrivateKeyResponse._();

  factory GetChequePrivateKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChequePrivateKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChequePrivateKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChequePrivateKeyResponse copyWith(
          void Function(GetChequePrivateKeyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetChequePrivateKeyResponse))
          as GetChequePrivateKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyResponse create() =>
      GetChequePrivateKeyResponse._();
  @$core.override
  GetChequePrivateKeyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyResponse>(create);
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
    final result = create();
    if (id != null) result.id = id;
    if (derivationIndex != null) result.derivationIndex = derivationIndex;
    if (address != null) result.address = address;
    if (expectedAmountSats != null)
      result.expectedAmountSats = expectedAmountSats;
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
      create()..mergeFromBuffer(data, registry);
  factory Cheque.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Cheque',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'derivationIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'funded')
    ..pPS(6, _omitFieldNames ? '' : 'fundedTxids')
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'fundedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(10, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(11, _omitFieldNames ? '' : 'sweptTxid')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'sweptAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cheque clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cheque copyWith(void Function(Cheque) updates) =>
      super.copyWith((message) => updates(message as Cheque)) as Cheque;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cheque create() => Cheque._();
  @$core.override
  Cheque createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Cheque getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cheque>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListChequesRequest._();

  factory ListChequesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListChequesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListChequesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesRequest copyWith(void Function(ListChequesRequest) updates) =>
      super.copyWith((message) => updates(message as ListChequesRequest))
          as ListChequesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListChequesRequest create() => ListChequesRequest._();
  @$core.override
  ListChequesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListChequesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListChequesRequest>(create);
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
    final result = create();
    if (cheques != null) result.cheques.addAll(cheques);
    return result;
  }

  ListChequesResponse._();

  factory ListChequesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListChequesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListChequesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<Cheque>(1, _omitFieldNames ? '' : 'cheques',
        subBuilder: Cheque.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListChequesResponse copyWith(void Function(ListChequesResponse) updates) =>
      super.copyWith((message) => updates(message as ListChequesResponse))
          as ListChequesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListChequesResponse create() => ListChequesResponse._();
  @$core.override
  ListChequesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListChequesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListChequesResponse>(create);
  static ListChequesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Cheque> get cheques => $_getList(0);
}

class CheckChequeFundingRequest extends $pb.GeneratedMessage {
  factory CheckChequeFundingRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  CheckChequeFundingRequest._();

  factory CheckChequeFundingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckChequeFundingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckChequeFundingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingRequest copyWith(
          void Function(CheckChequeFundingRequest) updates) =>
      super.copyWith((message) => updates(message as CheckChequeFundingRequest))
          as CheckChequeFundingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingRequest create() => CheckChequeFundingRequest._();
  @$core.override
  CheckChequeFundingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingRequest>(create);
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
    final result = create();
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
      create()..mergeFromBuffer(data, registry);
  factory CheckChequeFundingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckChequeFundingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'funded')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(3, _omitFieldNames ? '' : 'fundedTxids')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'fundedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'minConfirmations',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckChequeFundingResponse copyWith(
          void Function(CheckChequeFundingResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CheckChequeFundingResponse))
          as CheckChequeFundingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingResponse create() => CheckChequeFundingResponse._();
  @$core.override
  CheckChequeFundingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingResponse>(create);
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

class SweepChequeRequest extends $pb.GeneratedMessage {
  factory SweepChequeRequest({
    $core.String? walletId,
    $core.String? privateKeyWif,
    $core.String? destinationAddress,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (destinationAddress != null)
      result.destinationAddress = destinationAddress;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  SweepChequeRequest._();

  factory SweepChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SweepChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SweepChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(3, _omitFieldNames ? '' : 'destinationAddress')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeRequest copyWith(void Function(SweepChequeRequest) updates) =>
      super.copyWith((message) => updates(message as SweepChequeRequest))
          as SweepChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SweepChequeRequest create() => SweepChequeRequest._();
  @$core.override
  SweepChequeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SweepChequeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SweepChequeRequest>(create);
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
  }) {
    final result = create();
    if (txid != null) result.txid = txid;
    if (amountSats != null) result.amountSats = amountSats;
    return result;
  }

  SweepChequeResponse._();

  factory SweepChequeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SweepChequeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SweepChequeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SweepChequeResponse copyWith(void Function(SweepChequeResponse) updates) =>
      super.copyWith((message) => updates(message as SweepChequeResponse))
          as SweepChequeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SweepChequeResponse create() => SweepChequeResponse._();
  @$core.override
  SweepChequeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SweepChequeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SweepChequeResponse>(create);
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
}

class DeleteChequeRequest extends $pb.GeneratedMessage {
  factory DeleteChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (id != null) result.id = id;
    return result;
  }

  DeleteChequeRequest._();

  factory DeleteChequeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteChequeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteChequeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChequeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChequeRequest copyWith(void Function(DeleteChequeRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteChequeRequest))
          as DeleteChequeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteChequeRequest create() => DeleteChequeRequest._();
  @$core.override
  DeleteChequeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteChequeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteChequeRequest>(create);
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

class CreateBitcoinCoreWalletRequest extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletRequest({
    $core.String? seedHex,
    $core.String? name,
  }) {
    final result = create();
    if (seedHex != null) result.seedHex = seedHex;
    if (name != null) result.name = name;
    return result;
  }

  CreateBitcoinCoreWalletRequest._();

  factory CreateBitcoinCoreWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBitcoinCoreWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBitcoinCoreWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'seedHex')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletRequest copyWith(
          void Function(CreateBitcoinCoreWalletRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateBitcoinCoreWalletRequest))
          as CreateBitcoinCoreWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest create() =>
      CreateBitcoinCoreWalletRequest._();
  @$core.override
  CreateBitcoinCoreWalletRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletRequest>(create);
  static CreateBitcoinCoreWalletRequest? _defaultInstance;

  /// BIP32 seed as hex string (64 bytes = 128 hex chars)
  /// This is the output of BIP39 PBKDF2(mnemonic + passphrase)
  @$pb.TagNumber(1)
  $core.String get seedHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set seedHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeedHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeedHex() => $_clearField(1);

  /// Wallet name for display
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class CreateBitcoinCoreWalletResponse extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletResponse({
    $core.String? walletId,
    $core.String? coreWalletName,
    $core.String? firstAddress,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (coreWalletName != null) result.coreWalletName = coreWalletName;
    if (firstAddress != null) result.firstAddress = firstAddress;
    return result;
  }

  CreateBitcoinCoreWalletResponse._();

  factory CreateBitcoinCoreWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBitcoinCoreWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBitcoinCoreWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'coreWalletName')
    ..aOS(3, _omitFieldNames ? '' : 'firstAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletResponse copyWith(
          void Function(CreateBitcoinCoreWalletResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateBitcoinCoreWalletResponse))
          as CreateBitcoinCoreWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse create() =>
      CreateBitcoinCoreWalletResponse._();
  @$core.override
  CreateBitcoinCoreWalletResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletResponse>(
          create);
  static CreateBitcoinCoreWalletResponse? _defaultInstance;

  /// The wallet ID that was created
  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// The Bitcoin Core wallet name
  @$pb.TagNumber(2)
  $core.String get coreWalletName => $_getSZ(1);
  @$pb.TagNumber(2)
  set coreWalletName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCoreWalletName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoreWalletName() => $_clearField(2);

  /// First receiving address for verification
  @$pb.TagNumber(3)
  $core.String get firstAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set firstAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFirstAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearFirstAddress() => $_clearField(3);
}

/// UTXO Coin Control metadata
class UTXOMetadata extends $pb.GeneratedMessage {
  factory UTXOMetadata({
    $core.String? outpoint,
    $core.bool? isFrozen_2,
    $core.String? label,
  }) {
    final result = create();
    if (outpoint != null) result.outpoint = outpoint;
    if (isFrozen_2 != null) result.isFrozen_2 = isFrozen_2;
    if (label != null) result.label = label;
    return result;
  }

  UTXOMetadata._();

  factory UTXOMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UTXOMetadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UTXOMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOMetadata copyWith(void Function(UTXOMetadata) updates) =>
      super.copyWith((message) => updates(message as UTXOMetadata))
          as UTXOMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOMetadata create() => UTXOMetadata._();
  @$core.override
  UTXOMetadata createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UTXOMetadata getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UTXOMetadata>(create);
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
    final result = create();
    if (outpoint != null) result.outpoint = outpoint;
    if (isFrozen_2 != null) result.isFrozen_2 = isFrozen_2;
    if (label != null) result.label = label;
    return result;
  }

  SetUTXOMetadataRequest._();

  factory SetUTXOMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetUTXOMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetUTXOMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUTXOMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUTXOMetadataRequest copyWith(
          void Function(SetUTXOMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as SetUTXOMetadataRequest))
          as SetUTXOMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetUTXOMetadataRequest create() => SetUTXOMetadataRequest._();
  @$core.override
  SetUTXOMetadataRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetUTXOMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetUTXOMetadataRequest>(create);
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
    final result = create();
    if (outpoints != null) result.outpoints.addAll(outpoints);
    return result;
  }

  GetUTXOMetadataRequest._();

  factory GetUTXOMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUTXOMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUTXOMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'outpoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataRequest copyWith(
          void Function(GetUTXOMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as GetUTXOMetadataRequest))
          as GetUTXOMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataRequest create() => GetUTXOMetadataRequest._();
  @$core.override
  GetUTXOMetadataRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataRequest>(create);
  static GetUTXOMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get outpoints => $_getList(0);
}

class GetUTXOMetadataResponse extends $pb.GeneratedMessage {
  factory GetUTXOMetadataResponse({
    $core.Iterable<$core.MapEntry<$core.String, UTXOMetadata>>? metadata,
  }) {
    final result = create();
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  GetUTXOMetadataResponse._();

  factory GetUTXOMetadataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUTXOMetadataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUTXOMetadataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..m<$core.String, UTXOMetadata>(1, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'GetUTXOMetadataResponse.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: UTXOMetadata.create,
        valueDefaultOrMaker: UTXOMetadata.getDefault,
        packageName: const $pb.PackageName('wallet.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXOMetadataResponse copyWith(
          void Function(GetUTXOMetadataResponse) updates) =>
      super.copyWith((message) => updates(message as GetUTXOMetadataResponse))
          as GetUTXOMetadataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataResponse create() => GetUTXOMetadataResponse._();
  @$core.override
  GetUTXOMetadataResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataResponse>(create);
  static GetUTXOMetadataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, UTXOMetadata> get metadata => $_getMap(0);
}

class SetCoinSelectionStrategyRequest extends $pb.GeneratedMessage {
  factory SetCoinSelectionStrategyRequest({
    CoinSelectionStrategy? strategy,
  }) {
    final result = create();
    if (strategy != null) result.strategy = strategy;
    return result;
  }

  SetCoinSelectionStrategyRequest._();

  factory SetCoinSelectionStrategyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCoinSelectionStrategyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCoinSelectionStrategyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aE<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy',
        enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoinSelectionStrategyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoinSelectionStrategyRequest copyWith(
          void Function(SetCoinSelectionStrategyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetCoinSelectionStrategyRequest))
          as SetCoinSelectionStrategyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCoinSelectionStrategyRequest create() =>
      SetCoinSelectionStrategyRequest._();
  @$core.override
  SetCoinSelectionStrategyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCoinSelectionStrategyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCoinSelectionStrategyRequest>(
          create);
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
    final result = create();
    if (strategy != null) result.strategy = strategy;
    return result;
  }

  GetCoinSelectionStrategyResponse._();

  factory GetCoinSelectionStrategyResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCoinSelectionStrategyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCoinSelectionStrategyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aE<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy',
        enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinSelectionStrategyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinSelectionStrategyResponse copyWith(
          void Function(GetCoinSelectionStrategyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCoinSelectionStrategyResponse))
          as GetCoinSelectionStrategyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinSelectionStrategyResponse create() =>
      GetCoinSelectionStrategyResponse._();
  @$core.override
  GetCoinSelectionStrategyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCoinSelectionStrategyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoinSelectionStrategyResponse>(
          create);
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
    final result = create();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionDetailsRequest._();

  factory GetTransactionDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTransactionDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest copyWith(
          void Function(GetTransactionDetailsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetTransactionDetailsRequest))
          as GetTransactionDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest create() =>
      GetTransactionDetailsRequest._();
  @$core.override
  GetTransactionDetailsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsRequest>(create);
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
  }) {
    final result = create();
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
    return result;
  }

  GetTransactionDetailsResponse._();

  factory GetTransactionDetailsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTransactionDetailsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
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
    ..pPM<TransactionInput>(12, _omitFieldNames ? '' : 'inputs',
        subBuilder: TransactionInput.create)
    ..aInt64(13, _omitFieldNames ? '' : 'totalInputSats')
    ..pPM<TransactionOutput>(14, _omitFieldNames ? '' : 'outputs',
        subBuilder: TransactionOutput.create)
    ..aInt64(15, _omitFieldNames ? '' : 'totalOutputSats')
    ..aOS(16, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse copyWith(
          void Function(GetTransactionDetailsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTransactionDetailsResponse))
          as GetTransactionDetailsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse create() =>
      GetTransactionDetailsResponse._();
  @$core.override
  GetTransactionDetailsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsResponse>(create);
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
    final result = create();
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
      create()..mergeFromBuffer(data, registry);
  factory TransactionInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransactionInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
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
      super.copyWith((message) => updates(message as TransactionInput))
          as TransactionInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionInput create() => TransactionInput._();
  @$core.override
  TransactionInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransactionInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransactionInput>(create);
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
  }) {
    final result = create();
    if (index != null) result.index = index;
    if (valueSats != null) result.valueSats = valueSats;
    if (address != null) result.address = address;
    if (scriptType != null) result.scriptType = scriptType;
    if (scriptPubkeyAsm != null) result.scriptPubkeyAsm = scriptPubkeyAsm;
    if (scriptPubkeyHex != null) result.scriptPubkeyHex = scriptPubkeyHex;
    return result;
  }

  TransactionOutput._();

  factory TransactionOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransactionOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransactionOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'scriptType')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubkeyAsm')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput copyWith(void Function(TransactionOutput) updates) =>
      super.copyWith((message) => updates(message as TransactionOutput))
          as TransactionOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionOutput create() => TransactionOutput._();
  @$core.override
  TransactionOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransactionOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransactionOutput>(create);
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
}

/// UTXO Distribution - for chart visualization
class GetUTXODistributionRequest extends $pb.GeneratedMessage {
  factory GetUTXODistributionRequest({
    $core.String? walletId,
    $core.int? maxBuckets,
  }) {
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (maxBuckets != null) result.maxBuckets = maxBuckets;
    return result;
  }

  GetUTXODistributionRequest._();

  factory GetUTXODistributionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUTXODistributionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUTXODistributionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'maxBuckets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionRequest copyWith(
          void Function(GetUTXODistributionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetUTXODistributionRequest))
          as GetUTXODistributionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionRequest create() => GetUTXODistributionRequest._();
  @$core.override
  GetUTXODistributionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionRequest>(create);
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
    final result = create();
    if (buckets != null) result.buckets.addAll(buckets);
    return result;
  }

  GetUTXODistributionResponse._();

  factory GetUTXODistributionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUTXODistributionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUTXODistributionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<UTXOBucket>(1, _omitFieldNames ? '' : 'buckets',
        subBuilder: UTXOBucket.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUTXODistributionResponse copyWith(
          void Function(GetUTXODistributionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetUTXODistributionResponse))
          as GetUTXODistributionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionResponse create() =>
      GetUTXODistributionResponse._();
  @$core.override
  GetUTXODistributionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionResponse>(create);
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
    final result = create();
    if (label != null) result.label = label;
    if (valueSats != null) result.valueSats = valueSats;
    if (count != null) result.count = count;
    if (outpoints != null) result.outpoints.addAll(outpoints);
    return result;
  }

  UTXOBucket._();

  factory UTXOBucket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UTXOBucket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UTXOBucket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
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
  static UTXOBucket create() => UTXOBucket._();
  @$core.override
  UTXOBucket createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UTXOBucket getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UTXOBucket>(create);
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
    final result = create();
    if (txid != null) result.txid = txid;
    return result;
  }

  BumpFeeRequest._();

  factory BumpFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BumpFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BumpFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) =>
      super.copyWith((message) => updates(message as BumpFeeRequest))
          as BumpFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest create() => BumpFeeRequest._();
  @$core.override
  BumpFeeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(create);
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
    final result = create();
    if (txid != null) result.txid = txid;
    if (originalFee != null) result.originalFee = originalFee;
    if (newFee != null) result.newFee = newFee;
    return result;
  }

  BumpFeeResponse._();

  factory BumpFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BumpFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BumpFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aD(2, _omitFieldNames ? '' : 'originalFee')
    ..aD(3, _omitFieldNames ? '' : 'newFee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) =>
      super.copyWith((message) => updates(message as BumpFeeResponse))
          as BumpFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse create() => BumpFeeResponse._();
  @$core.override
  BumpFeeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(create);
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
    final result = create();
    if (walletId != null) result.walletId = walletId;
    if (targetSats != null) result.targetSats = targetSats;
    if (feeSatsPerVbyte != null) result.feeSatsPerVbyte = feeSatsPerVbyte;
    if (numOutputs != null) result.numOutputs = numOutputs;
    if (strategy != null) result.strategy = strategy;
    if (frozenOutpoints != null) result.frozenOutpoints.addAll(frozenOutpoints);
    if (requiredOutpoints != null)
      result.requiredOutpoints.addAll(requiredOutpoints);
    return result;
  }

  SelectCoinsRequest._();

  factory SelectCoinsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SelectCoinsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SelectCoinsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'targetSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSatsPerVbyte')
    ..aI(4, _omitFieldNames ? '' : 'numOutputs')
    ..aE<CoinSelectionStrategy>(5, _omitFieldNames ? '' : 'strategy',
        enumValues: CoinSelectionStrategy.values)
    ..pPS(6, _omitFieldNames ? '' : 'frozenOutpoints')
    ..pPS(7, _omitFieldNames ? '' : 'requiredOutpoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsRequest copyWith(void Function(SelectCoinsRequest) updates) =>
      super.copyWith((message) => updates(message as SelectCoinsRequest))
          as SelectCoinsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SelectCoinsRequest create() => SelectCoinsRequest._();
  @$core.override
  SelectCoinsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SelectCoinsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SelectCoinsRequest>(create);
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
    final result = create();
    if (selectedUtxos != null) result.selectedUtxos.addAll(selectedUtxos);
    if (totalInputSats != null) result.totalInputSats = totalInputSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (changeSats != null) result.changeSats = changeSats;
    return result;
  }

  SelectCoinsResponse._();

  factory SelectCoinsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SelectCoinsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SelectCoinsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'selectedUtxos',
        subBuilder: UnspentOutput.create)
    ..aInt64(2, _omitFieldNames ? '' : 'totalInputSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'changeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectCoinsResponse copyWith(void Function(SelectCoinsResponse) updates) =>
      super.copyWith((message) => updates(message as SelectCoinsResponse))
          as SelectCoinsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SelectCoinsResponse create() => SelectCoinsResponse._();
  @$core.override
  SelectCoinsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SelectCoinsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SelectCoinsResponse>(create);
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
    final result = create();
    if (backupData != null) result.backupData = backupData;
    if (suggestedFilename != null) result.suggestedFilename = suggestedFilename;
    return result;
  }

  CreateBackupResponse._();

  factory CreateBackupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBackupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBackupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'suggestedFilename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBackupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBackupResponse copyWith(void Function(CreateBackupResponse) updates) =>
      super.copyWith((message) => updates(message as CreateBackupResponse))
          as CreateBackupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBackupResponse create() => CreateBackupResponse._();
  @$core.override
  CreateBackupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBackupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBackupResponse>(create);
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
    final result = create();
    if (backupData != null) result.backupData = backupData;
    if (filename != null) result.filename = filename;
    return result;
  }

  RestoreBackupRequest._();

  factory RestoreBackupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestoreBackupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestoreBackupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreBackupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreBackupRequest copyWith(void Function(RestoreBackupRequest) updates) =>
      super.copyWith((message) => updates(message as RestoreBackupRequest))
          as RestoreBackupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestoreBackupRequest create() => RestoreBackupRequest._();
  @$core.override
  RestoreBackupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestoreBackupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreBackupRequest>(create);
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
    final result = create();
    if (backupData != null) result.backupData = backupData;
    if (filename != null) result.filename = filename;
    return result;
  }

  ValidateBackupRequest._();

  factory ValidateBackupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateBackupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateBackupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'backupData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupRequest copyWith(
          void Function(ValidateBackupRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateBackupRequest))
          as ValidateBackupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateBackupRequest create() => ValidateBackupRequest._();
  @$core.override
  ValidateBackupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateBackupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBackupRequest>(create);
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
    final result = create();
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
      create()..mergeFromBuffer(data, registry);
  factory ValidateBackupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateBackupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOB(3, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(4, _omitFieldNames ? '' : 'hasMultisig')
    ..aOB(5, _omitFieldNames ? '' : 'hasTransactions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBackupResponse copyWith(
          void Function(ValidateBackupResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateBackupResponse))
          as ValidateBackupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateBackupResponse create() => ValidateBackupResponse._();
  @$core.override
  ValidateBackupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateBackupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBackupResponse>(create);
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

  $async.Future<CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
          $pb.ClientContext? ctx, CreateBitcoinCoreWalletRequest request) =>
      _client.invoke<CreateBitcoinCoreWalletResponse>(
          ctx,
          'WalletService',
          'CreateBitcoinCoreWallet',
          request,
          CreateBitcoinCoreWalletResponse());
  $async.Future<SendTransactionResponse> sendTransaction(
          $pb.ClientContext? ctx, SendTransactionRequest request) =>
      _client.invoke<SendTransactionResponse>(ctx, 'WalletService',
          'SendTransaction', request, SendTransactionResponse());
  $async.Future<GetBalanceResponse> getBalance(
          $pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(
          ctx, 'WalletService', 'GetBalance', request, GetBalanceResponse());

  /// Problem: deriving nilly willy here is potentially problematic. There's no way of listing
  /// out unused addresses, so we risk crossing the sync gap.
  $async.Future<GetNewAddressResponse> getNewAddress(
          $pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'WalletService',
          'GetNewAddress', request, GetNewAddressResponse());
  $async.Future<ListTransactionsResponse> listTransactions(
          $pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(ctx, 'WalletService',
          'ListTransactions', request, ListTransactionsResponse());
  $async.Future<ListUnspentResponse> listUnspent(
          $pb.ClientContext? ctx, ListUnspentRequest request) =>
      _client.invoke<ListUnspentResponse>(
          ctx, 'WalletService', 'ListUnspent', request, ListUnspentResponse());
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses(
          $pb.ClientContext? ctx, ListReceiveAddressesRequest request) =>
      _client.invoke<ListReceiveAddressesResponse>(ctx, 'WalletService',
          'ListReceiveAddresses', request, ListReceiveAddressesResponse());
  $async.Future<ListSidechainDepositsResponse> listSidechainDeposits(
          $pb.ClientContext? ctx, ListSidechainDepositsRequest request) =>
      _client.invoke<ListSidechainDepositsResponse>(ctx, 'WalletService',
          'ListSidechainDeposits', request, ListSidechainDepositsResponse());
  $async.Future<CreateSidechainDepositResponse> createSidechainDeposit(
          $pb.ClientContext? ctx, CreateSidechainDepositRequest request) =>
      _client.invoke<CreateSidechainDepositResponse>(ctx, 'WalletService',
          'CreateSidechainDeposit', request, CreateSidechainDepositResponse());
  $async.Future<SignMessageResponse> signMessage(
          $pb.ClientContext? ctx, SignMessageRequest request) =>
      _client.invoke<SignMessageResponse>(
          ctx, 'WalletService', 'SignMessage', request, SignMessageResponse());
  $async.Future<VerifyMessageResponse> verifyMessage(
          $pb.ClientContext? ctx, VerifyMessageRequest request) =>
      _client.invoke<VerifyMessageResponse>(ctx, 'WalletService',
          'VerifyMessage', request, VerifyMessageResponse());
  $async.Future<GetStatsResponse> getStats(
          $pb.ClientContext? ctx, GetStatsRequest request) =>
      _client.invoke<GetStatsResponse>(
          ctx, 'WalletService', 'GetStats', request, GetStatsResponse());

  /// Wallet unlock/lock for cheque operations
  $async.Future<$2.Empty> unlockWallet(
          $pb.ClientContext? ctx, UnlockWalletRequest request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'UnlockWallet', request, $2.Empty());
  $async.Future<$2.Empty> lockWallet(
          $pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'LockWallet', request, $2.Empty());
  $async.Future<$2.Empty> isWalletUnlocked(
          $pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'IsWalletUnlocked', request, $2.Empty());

  /// Cheque operations
  $async.Future<CreateChequeResponse> createCheque(
          $pb.ClientContext? ctx, CreateChequeRequest request) =>
      _client.invoke<CreateChequeResponse>(ctx, 'WalletService', 'CreateCheque',
          request, CreateChequeResponse());
  $async.Future<GetChequeResponse> getCheque(
          $pb.ClientContext? ctx, GetChequeRequest request) =>
      _client.invoke<GetChequeResponse>(
          ctx, 'WalletService', 'GetCheque', request, GetChequeResponse());
  $async.Future<GetChequePrivateKeyResponse> getChequePrivateKey(
          $pb.ClientContext? ctx, GetChequePrivateKeyRequest request) =>
      _client.invoke<GetChequePrivateKeyResponse>(ctx, 'WalletService',
          'GetChequePrivateKey', request, GetChequePrivateKeyResponse());
  $async.Future<ListChequesResponse> listCheques(
          $pb.ClientContext? ctx, ListChequesRequest request) =>
      _client.invoke<ListChequesResponse>(
          ctx, 'WalletService', 'ListCheques', request, ListChequesResponse());
  $async.Future<CheckChequeFundingResponse> checkChequeFunding(
          $pb.ClientContext? ctx, CheckChequeFundingRequest request) =>
      _client.invoke<CheckChequeFundingResponse>(ctx, 'WalletService',
          'CheckChequeFunding', request, CheckChequeFundingResponse());
  $async.Future<SweepChequeResponse> sweepCheque(
          $pb.ClientContext? ctx, SweepChequeRequest request) =>
      _client.invoke<SweepChequeResponse>(
          ctx, 'WalletService', 'SweepCheque', request, SweepChequeResponse());
  $async.Future<$2.Empty> deleteCheque(
          $pb.ClientContext? ctx, DeleteChequeRequest request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'DeleteCheque', request, $2.Empty());

  /// UTXO Coin Control
  $async.Future<$2.Empty> setUTXOMetadata(
          $pb.ClientContext? ctx, SetUTXOMetadataRequest request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'SetUTXOMetadata', request, $2.Empty());
  $async.Future<GetUTXOMetadataResponse> getUTXOMetadata(
          $pb.ClientContext? ctx, GetUTXOMetadataRequest request) =>
      _client.invoke<GetUTXOMetadataResponse>(ctx, 'WalletService',
          'GetUTXOMetadata', request, GetUTXOMetadataResponse());

  /// Coin Selection Preferences
  $async.Future<$2.Empty> setCoinSelectionStrategy(
          $pb.ClientContext? ctx, SetCoinSelectionStrategyRequest request) =>
      _client.invoke<$2.Empty>(ctx, 'WalletService', 'SetCoinSelectionStrategy',
          request, $2.Empty());
  $async.Future<GetCoinSelectionStrategyResponse> getCoinSelectionStrategy(
          $pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<GetCoinSelectionStrategyResponse>(
          ctx,
          'WalletService',
          'GetCoinSelectionStrategy',
          request,
          GetCoinSelectionStrategyResponse());

  /// Transaction Details (enriched with input values/addresses)
  $async.Future<GetTransactionDetailsResponse> getTransactionDetails(
          $pb.ClientContext? ctx, GetTransactionDetailsRequest request) =>
      _client.invoke<GetTransactionDetailsResponse>(ctx, 'WalletService',
          'GetTransactionDetails', request, GetTransactionDetailsResponse());

  /// UTXO Distribution (for chart visualization)
  $async.Future<GetUTXODistributionResponse> getUTXODistribution(
          $pb.ClientContext? ctx, GetUTXODistributionRequest request) =>
      _client.invoke<GetUTXODistributionResponse>(ctx, 'WalletService',
          'GetUTXODistribution', request, GetUTXODistributionResponse());

  /// RBF - Replace-By-Fee for unconfirmed transactions
  $async.Future<BumpFeeResponse> bumpFee(
          $pb.ClientContext? ctx, BumpFeeRequest request) =>
      _client.invoke<BumpFeeResponse>(
          ctx, 'WalletService', 'BumpFee', request, BumpFeeResponse());

  /// Coin Selection - Select UTXOs for a transaction
  $async.Future<SelectCoinsResponse> selectCoins(
          $pb.ClientContext? ctx, SelectCoinsRequest request) =>
      _client.invoke<SelectCoinsResponse>(
          ctx, 'WalletService', 'SelectCoins', request, SelectCoinsResponse());

  /// Backup / Restore
  $async.Future<CreateBackupResponse> createBackup(
          $pb.ClientContext? ctx, $2.Empty request) =>
      _client.invoke<CreateBackupResponse>(ctx, 'WalletService', 'CreateBackup',
          request, CreateBackupResponse());
  $async.Future<$2.Empty> restoreBackup(
          $pb.ClientContext? ctx, RestoreBackupRequest request) =>
      _client.invoke<$2.Empty>(
          ctx, 'WalletService', 'RestoreBackup', request, $2.Empty());
  $async.Future<ValidateBackupResponse> validateBackup(
          $pb.ClientContext? ctx, ValidateBackupRequest request) =>
      _client.invoke<ValidateBackupResponse>(ctx, 'WalletService',
          'ValidateBackup', request, ValidateBackupResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
