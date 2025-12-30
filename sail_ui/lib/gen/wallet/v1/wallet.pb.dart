//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
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

import '../../bitwindowd/v1/bitwindowd.pb.dart' as $2;
import '../../google/protobuf/empty.pb.dart' as $1;
import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'wallet.pbenum.dart';

export 'wallet.pbenum.dart';

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetBalanceRequest._() : super();
  factory GetBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
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

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetNewAddressRequest._() : super();
  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
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

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
    $core.int? index,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (index != null) {
      $result.index = index;
    }
    return $result;
  }
  GetNewAddressResponse._() : super();
  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.OU3)
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

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => clearField(2);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListTransactionsRequest._() : super();
  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest clone() => ListTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  ListTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsRequest> createRepeated() => $pb.PbList<ListTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(create);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListUnspentRequest._() : super();
  factory ListUnspentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentRequest clone() => ListUnspentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) => super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest create() => ListUnspentRequest._();
  ListUnspentRequest createEmptyInstance() => create();
  static $pb.PbList<ListUnspentRequest> createRepeated() => $pb.PbList<ListUnspentRequest>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(create);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class ListReceiveAddressesRequest extends $pb.GeneratedMessage {
  factory ListReceiveAddressesRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListReceiveAddressesRequest._() : super();
  factory ListReceiveAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListReceiveAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesRequest clone() => ListReceiveAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesRequest copyWith(void Function(ListReceiveAddressesRequest) updates) => super.copyWith((message) => updates(message as ListReceiveAddressesRequest)) as ListReceiveAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest create() => ListReceiveAddressesRequest._();
  ListReceiveAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<ListReceiveAddressesRequest> createRepeated() => $pb.PbList<ListReceiveAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesRequest>(create);
  static ListReceiveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetStatsRequest extends $pb.GeneratedMessage {
  factory GetStatsRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetStatsRequest._() : super();
  factory GetStatsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStatsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStatsRequest clone() => GetStatsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) => super.copyWith((message) => updates(message as GetStatsRequest)) as GetStatsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsRequest create() => GetStatsRequest._();
  GetStatsRequest createEmptyInstance() => create();
  static $pb.PbList<GetStatsRequest> createRepeated() => $pb.PbList<GetStatsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(create);
  static GetStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.String? walletId,
    $core.Map<$core.String, $fixnum.Int64>? destinations,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? fixedFeeSats,
    $core.String? opReturnMessage,
    $core.String? label,
    $core.Iterable<UnspentOutput>? requiredInputs,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (feeSatPerVbyte != null) {
      $result.feeSatPerVbyte = feeSatPerVbyte;
    }
    if (fixedFeeSats != null) {
      $result.fixedFeeSats = fixedFeeSats;
    }
    if (opReturnMessage != null) {
      $result.opReturnMessage = opReturnMessage;
    }
    if (label != null) {
      $result.label = label;
    }
    if (requiredInputs != null) {
      $result.requiredInputs.addAll(requiredInputs);
    }
    return $result;
  }
  SendTransactionRequest._() : super();
  factory SendTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendTransactionRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OU6, packageName: const $pb.PackageName('wallet.v1'))
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'fixedFeeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'opReturnMessage')
    ..aOS(6, _omitFieldNames ? '' : 'label')
    ..pc<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendTransactionRequest clone() => SendTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendTransactionRequest copyWith(void Function(SendTransactionRequest) updates) => super.copyWith((message) => updates(message as SendTransactionRequest)) as SendTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest create() => SendTransactionRequest._();
  SendTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SendTransactionRequest> createRepeated() => $pb.PbList<SendTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest>(create);
  static SendTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  /// Map of destination address to amount in satoshi.
  @$pb.TagNumber(2)
  $core.Map<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  /// Fee rate, measured in sat/vb. If set to zero, a reasonable
  /// rate is used by asking Core for an estimate.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatPerVbyte() => clearField(3);

  /// Hard-coded amount, in sats.
  @$pb.TagNumber(4)
  $fixnum.Int64 get fixedFeeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set fixedFeeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFixedFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFixedFeeSats() => clearField(4);

  /// Message to include as an OP_RETURN output
  @$pb.TagNumber(5)
  $core.String get opReturnMessage => $_getSZ(4);
  @$pb.TagNumber(5)
  set opReturnMessage($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOpReturnMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearOpReturnMessage() => clearField(5);

  /// If set, will save the address with this label in the address book
  @$pb.TagNumber(6)
  $core.String get label => $_getSZ(5);
  @$pb.TagNumber(6)
  set label($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearLabel() => clearField(6);

  /// UTXOs that must be included in the transaction.
  @$pb.TagNumber(7)
  $core.List<UnspentOutput> get requiredInputs => $_getList(6);
}

class SendTransactionResponse extends $pb.GeneratedMessage {
  factory SendTransactionResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SendTransactionResponse._() : super();
  factory SendTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendTransactionResponse clone() => SendTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendTransactionResponse copyWith(void Function(SendTransactionResponse) updates) => super.copyWith((message) => updates(message as SendTransactionResponse)) as SendTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse create() => SendTransactionResponse._();
  SendTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SendTransactionResponse> createRepeated() => $pb.PbList<SendTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendTransactionResponse>(create);
  static SendTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $fixnum.Int64? confirmedSatoshi,
    $fixnum.Int64? pendingSatoshi,
  }) {
    final $result = create();
    if (confirmedSatoshi != null) {
      $result.confirmedSatoshi = confirmedSatoshi;
    }
    if (pendingSatoshi != null) {
      $result.pendingSatoshi = pendingSatoshi;
    }
    return $result;
  }
  GetBalanceResponse._() : super();
  factory GetBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'confirmedSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'pendingSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
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
  $fixnum.Int64 get confirmedSatoshi => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSatoshi($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSatoshi() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSatoshi() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSatoshi => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSatoshi($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPendingSatoshi() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSatoshi() => clearField(2);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<WalletTransaction>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListTransactionsResponse._() : super();
  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<WalletTransaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: WalletTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse clone() => ListTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  ListTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsResponse> createRepeated() => $pb.PbList<ListTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(create);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WalletTransaction> get transactions => $_getList(0);
}

class UnspentOutput extends $pb.GeneratedMessage {
  factory UnspentOutput({
    $core.String? output,
    $core.String? address,
    $core.String? label,
    $fixnum.Int64? valueSats,
    $core.bool? isChange,
    $0.Timestamp? receivedAt,
    $2.DenialInfo? denialInfo,
  }) {
    final $result = create();
    if (output != null) {
      $result.output = output;
    }
    if (address != null) {
      $result.address = address;
    }
    if (label != null) {
      $result.label = label;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (isChange != null) {
      $result.isChange = isChange;
    }
    if (receivedAt != null) {
      $result.receivedAt = receivedAt;
    }
    if (denialInfo != null) {
      $result.denialInfo = denialInfo;
    }
    return $result;
  }
  UnspentOutput._() : super();
  factory UnspentOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnspentOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'output')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'valueSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'receivedAt', subBuilder: $0.Timestamp.create)
    ..aOM<$2.DenialInfo>(7, _omitFieldNames ? '' : 'denialInfo', subBuilder: $2.DenialInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnspentOutput clone() => UnspentOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) => super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnspentOutput create() => UnspentOutput._();
  UnspentOutput createEmptyInstance() => create();
  static $pb.PbList<UnspentOutput> createRepeated() => $pb.PbList<UnspentOutput>();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(create);
  static UnspentOutput? _defaultInstance;

  /// The vout:index of the utxo
  @$pb.TagNumber(1)
  $core.String get output => $_getSZ(0);
  @$pb.TagNumber(1)
  set output($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOutput() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutput() => clearField(1);

  /// What address the utxo was received to.
  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  /// What label (if any) the address received to is labeled with.
  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);

  /// The value of the output, in satoshis.
  @$pb.TagNumber(4)
  $fixnum.Int64 get valueSats => $_getI64(3);
  @$pb.TagNumber(4)
  set valueSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasValueSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearValueSats() => clearField(4);

  /// Whether this is a change output.
  @$pb.TagNumber(5)
  $core.bool get isChange => $_getBF(4);
  @$pb.TagNumber(5)
  set isChange($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsChange() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsChange() => clearField(5);

  /// Timestamp of the utxo.
  @$pb.TagNumber(6)
  $0.Timestamp get receivedAt => $_getN(5);
  @$pb.TagNumber(6)
  set receivedAt($0.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasReceivedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearReceivedAt() => clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureReceivedAt() => $_ensure(5);

  /// If set, this utxo is part of a denial chain
  @$pb.TagNumber(7)
  $2.DenialInfo get denialInfo => $_getN(6);
  @$pb.TagNumber(7)
  set denialInfo($2.DenialInfo v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasDenialInfo() => $_has(6);
  @$pb.TagNumber(7)
  void clearDenialInfo() => clearField(7);
  @$pb.TagNumber(7)
  $2.DenialInfo ensureDenialInfo() => $_ensure(6);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? utxos,
  }) {
    final $result = create();
    if (utxos != null) {
      $result.utxos.addAll(utxos);
    }
    return $result;
  }
  ListUnspentResponse._() : super();
  factory ListUnspentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<UnspentOutput>(1, _omitFieldNames ? '' : 'utxos', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentResponse clone() => ListUnspentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) => super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse create() => ListUnspentResponse._();
  ListUnspentResponse createEmptyInstance() => create();
  static $pb.PbList<ListUnspentResponse> createRepeated() => $pb.PbList<ListUnspentResponse>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(create);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UnspentOutput> get utxos => $_getList(0);
}

class ListReceiveAddressesResponse extends $pb.GeneratedMessage {
  factory ListReceiveAddressesResponse({
    $core.Iterable<ReceiveAddress>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  ListReceiveAddressesResponse._() : super();
  factory ListReceiveAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListReceiveAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<ReceiveAddress>(1, _omitFieldNames ? '' : 'addresses', $pb.PbFieldType.PM, subBuilder: ReceiveAddress.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesResponse clone() => ListReceiveAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesResponse copyWith(void Function(ListReceiveAddressesResponse) updates) => super.copyWith((message) => updates(message as ListReceiveAddressesResponse)) as ListReceiveAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse create() => ListReceiveAddressesResponse._();
  ListReceiveAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<ListReceiveAddressesResponse> createRepeated() => $pb.PbList<ListReceiveAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesResponse>(create);
  static ListReceiveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ReceiveAddress> get addresses => $_getList(0);
}

class ReceiveAddress extends $pb.GeneratedMessage {
  factory ReceiveAddress({
    $core.String? address,
    $core.String? label,
    $fixnum.Int64? currentBalanceSat,
    $core.bool? isChange,
    $0.Timestamp? lastUsedAt,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (label != null) {
      $result.label = label;
    }
    if (currentBalanceSat != null) {
      $result.currentBalanceSat = currentBalanceSat;
    }
    if (isChange != null) {
      $result.isChange = isChange;
    }
    if (lastUsedAt != null) {
      $result.lastUsedAt = lastUsedAt;
    }
    return $result;
  }
  ReceiveAddress._() : super();
  factory ReceiveAddress.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReceiveAddress.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReceiveAddress', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'currentBalanceSat', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'isChange')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastUsedAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReceiveAddress clone() => ReceiveAddress()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReceiveAddress copyWith(void Function(ReceiveAddress) updates) => super.copyWith((message) => updates(message as ReceiveAddress)) as ReceiveAddress;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveAddress create() => ReceiveAddress._();
  ReceiveAddress createEmptyInstance() => create();
  static $pb.PbList<ReceiveAddress> createRepeated() => $pb.PbList<ReceiveAddress>();
  @$core.pragma('dart2js:noInline')
  static ReceiveAddress getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReceiveAddress>(create);
  static ReceiveAddress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get currentBalanceSat => $_getI64(2);
  @$pb.TagNumber(3)
  set currentBalanceSat($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrentBalanceSat() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentBalanceSat() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isChange => $_getBF(3);
  @$pb.TagNumber(4)
  set isChange($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsChange() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsChange() => clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get lastUsedAt => $_getN(4);
  @$pb.TagNumber(5)
  set lastUsedAt($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastUsedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastUsedAt() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLastUsedAt() => $_ensure(4);
}

class Confirmation extends $pb.GeneratedMessage {
  factory Confirmation({
    $core.int? height,
    $0.Timestamp? timestamp,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  Confirmation._() : super();
  factory Confirmation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Confirmation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Confirmation', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Confirmation clone() => Confirmation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Confirmation copyWith(void Function(Confirmation) updates) => super.copyWith((message) => updates(message as Confirmation)) as Confirmation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Confirmation create() => Confirmation._();
  Confirmation createEmptyInstance() => create();
  static $pb.PbList<Confirmation> createRepeated() => $pb.PbList<Confirmation>();
  @$core.pragma('dart2js:noInline')
  static Confirmation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Confirmation>(create);
  static Confirmation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (receivedSatoshi != null) {
      $result.receivedSatoshi = receivedSatoshi;
    }
    if (sentSatoshi != null) {
      $result.sentSatoshi = sentSatoshi;
    }
    if (address != null) {
      $result.address = address;
    }
    if (addressLabel != null) {
      $result.addressLabel = addressLabel;
    }
    if (note != null) {
      $result.note = note;
    }
    if (confirmationTime != null) {
      $result.confirmationTime = confirmationTime;
    }
    return $result;
  }
  WalletTransaction._() : super();
  factory WalletTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'receivedSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sentSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'address')
    ..aOS(6, _omitFieldNames ? '' : 'addressLabel')
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..aOM<Confirmation>(8, _omitFieldNames ? '' : 'confirmationTime', subBuilder: Confirmation.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletTransaction clone() => WalletTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletTransaction copyWith(void Function(WalletTransaction) updates) => super.copyWith((message) => updates(message as WalletTransaction)) as WalletTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletTransaction create() => WalletTransaction._();
  WalletTransaction createEmptyInstance() => create();
  static $pb.PbList<WalletTransaction> createRepeated() => $pb.PbList<WalletTransaction>();
  @$core.pragma('dart2js:noInline')
  static WalletTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletTransaction>(create);
  static WalletTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get receivedSatoshi => $_getI64(2);
  @$pb.TagNumber(3)
  set receivedSatoshi($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReceivedSatoshi() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedSatoshi() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sentSatoshi => $_getI64(3);
  @$pb.TagNumber(4)
  set sentSatoshi($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSentSatoshi() => $_has(3);
  @$pb.TagNumber(4)
  void clearSentSatoshi() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get address => $_getSZ(4);
  @$pb.TagNumber(5)
  set address($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddress() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get addressLabel => $_getSZ(5);
  @$pb.TagNumber(6)
  set addressLabel($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAddressLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddressLabel() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => clearField(7);

  @$pb.TagNumber(8)
  Confirmation get confirmationTime => $_getN(7);
  @$pb.TagNumber(8)
  set confirmationTime(Confirmation v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfirmationTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmationTime() => clearField(8);
  @$pb.TagNumber(8)
  Confirmation ensureConfirmationTime() => $_ensure(7);
}

class ListSidechainDepositsRequest extends $pb.GeneratedMessage {
  factory ListSidechainDepositsRequest({
    $core.String? walletId,
    $core.int? slot,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (slot != null) {
      $result.slot = slot;
    }
    return $result;
  }
  ListSidechainDepositsRequest._() : super();
  factory ListSidechainDepositsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsRequest clone() => ListSidechainDepositsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsRequest copyWith(void Function(ListSidechainDepositsRequest) updates) => super.copyWith((message) => updates(message as ListSidechainDepositsRequest)) as ListSidechainDepositsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest create() => ListSidechainDepositsRequest._();
  ListSidechainDepositsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositsRequest> createRepeated() => $pb.PbList<ListSidechainDepositsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsRequest>(create);
  static ListSidechainDepositsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get slot => $_getIZ(1);
  @$pb.TagNumber(2)
  set slot($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSlot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlot() => clearField(2);
}

class ListSidechainDepositsResponse_SidechainDeposit extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse_SidechainDeposit({
    $core.String? txid,
    $fixnum.Int64? amount,
    $fixnum.Int64? fee,
    $core.int? confirmations,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    return $result;
  }
  ListSidechainDepositsResponse_SidechainDeposit._() : super();
  factory ListSidechainDepositsResponse_SidechainDeposit.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositsResponse_SidechainDeposit.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsResponse.SidechainDeposit', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'fee')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsResponse_SidechainDeposit clone() => ListSidechainDepositsResponse_SidechainDeposit()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsResponse_SidechainDeposit copyWith(void Function(ListSidechainDepositsResponse_SidechainDeposit) updates) => super.copyWith((message) => updates(message as ListSidechainDepositsResponse_SidechainDeposit)) as ListSidechainDepositsResponse_SidechainDeposit;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse_SidechainDeposit create() => ListSidechainDepositsResponse_SidechainDeposit._();
  ListSidechainDepositsResponse_SidechainDeposit createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositsResponse_SidechainDeposit> createRepeated() => $pb.PbList<ListSidechainDepositsResponse_SidechainDeposit>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse_SidechainDeposit getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse_SidechainDeposit>(create);
  static ListSidechainDepositsResponse_SidechainDeposit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fee => $_getI64(2);
  @$pb.TagNumber(3)
  set fee($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearFee() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => clearField(4);
}

class ListSidechainDepositsResponse extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse({
    $core.Iterable<ListSidechainDepositsResponse_SidechainDeposit>? deposits,
  }) {
    final $result = create();
    if (deposits != null) {
      $result.deposits.addAll(deposits);
    }
    return $result;
  }
  ListSidechainDepositsResponse._() : super();
  factory ListSidechainDepositsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<ListSidechainDepositsResponse_SidechainDeposit>(1, _omitFieldNames ? '' : 'deposits', $pb.PbFieldType.PM, subBuilder: ListSidechainDepositsResponse_SidechainDeposit.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsResponse clone() => ListSidechainDepositsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositsResponse copyWith(void Function(ListSidechainDepositsResponse) updates) => super.copyWith((message) => updates(message as ListSidechainDepositsResponse)) as ListSidechainDepositsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse create() => ListSidechainDepositsResponse._();
  ListSidechainDepositsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositsResponse> createRepeated() => $pb.PbList<ListSidechainDepositsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse>(create);
  static ListSidechainDepositsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ListSidechainDepositsResponse_SidechainDeposit> get deposits => $_getList(0);
}

class CreateSidechainDepositRequest extends $pb.GeneratedMessage {
  factory CreateSidechainDepositRequest({
    $core.String? walletId,
    $fixnum.Int64? slot,
    $core.String? destination,
    $core.double? amount,
    $core.double? fee,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (slot != null) {
      $result.slot = slot;
    }
    if (destination != null) {
      $result.destination = destination;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    return $result;
  }
  CreateSidechainDepositRequest._() : super();
  factory CreateSidechainDepositRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainDepositRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'slot')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainDepositRequest clone() => CreateSidechainDepositRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainDepositRequest copyWith(void Function(CreateSidechainDepositRequest) updates) => super.copyWith((message) => updates(message as CreateSidechainDepositRequest)) as CreateSidechainDepositRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositRequest create() => CreateSidechainDepositRequest._();
  CreateSidechainDepositRequest createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainDepositRequest> createRepeated() => $pb.PbList<CreateSidechainDepositRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositRequest>(create);
  static CreateSidechainDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(2)
  $fixnum.Int64 get slot => $_getI64(1);
  @$pb.TagNumber(2)
  set slot($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSlot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlot() => clearField(2);

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => clearField(3);

  /// The amount in BTC to send. eg 0.1
  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);

  /// The fee in BTC
  @$pb.TagNumber(5)
  $core.double get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => clearField(5);
}

class CreateSidechainDepositResponse extends $pb.GeneratedMessage {
  factory CreateSidechainDepositResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateSidechainDepositResponse._() : super();
  factory CreateSidechainDepositResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainDepositResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainDepositResponse clone() => CreateSidechainDepositResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainDepositResponse copyWith(void Function(CreateSidechainDepositResponse) updates) => super.copyWith((message) => updates(message as CreateSidechainDepositResponse)) as CreateSidechainDepositResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositResponse create() => CreateSidechainDepositResponse._();
  CreateSidechainDepositResponse createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainDepositResponse> createRepeated() => $pb.PbList<CreateSidechainDepositResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainDepositResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainDepositResponse>(create);
  static CreateSidechainDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class SignMessageRequest extends $pb.GeneratedMessage {
  factory SignMessageRequest({
    $core.String? walletId,
    $core.String? message,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SignMessageRequest._() : super();
  factory SignMessageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignMessageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignMessageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignMessageRequest clone() => SignMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignMessageRequest copyWith(void Function(SignMessageRequest) updates) => super.copyWith((message) => updates(message as SignMessageRequest)) as SignMessageRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignMessageRequest create() => SignMessageRequest._();
  SignMessageRequest createEmptyInstance() => create();
  static $pb.PbList<SignMessageRequest> createRepeated() => $pb.PbList<SignMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static SignMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignMessageRequest>(create);
  static SignMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class SignMessageResponse extends $pb.GeneratedMessage {
  factory SignMessageResponse({
    $core.String? signature,
  }) {
    final $result = create();
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  SignMessageResponse._() : super();
  factory SignMessageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignMessageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignMessageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignMessageResponse clone() => SignMessageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignMessageResponse copyWith(void Function(SignMessageResponse) updates) => super.copyWith((message) => updates(message as SignMessageResponse)) as SignMessageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignMessageResponse create() => SignMessageResponse._();
  SignMessageResponse createEmptyInstance() => create();
  static $pb.PbList<SignMessageResponse> createRepeated() => $pb.PbList<SignMessageResponse>();
  @$core.pragma('dart2js:noInline')
  static SignMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignMessageResponse>(create);
  static SignMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => clearField(1);
}

class VerifyMessageRequest extends $pb.GeneratedMessage {
  factory VerifyMessageRequest({
    $core.String? walletId,
    $core.String? message,
    $core.String? signature,
    $core.String? publicKey,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (message != null) {
      $result.message = message;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    return $result;
  }
  VerifyMessageRequest._() : super();
  factory VerifyMessageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyMessageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyMessageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'signature')
    ..aOS(4, _omitFieldNames ? '' : 'publicKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyMessageRequest clone() => VerifyMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyMessageRequest copyWith(void Function(VerifyMessageRequest) updates) => super.copyWith((message) => updates(message as VerifyMessageRequest)) as VerifyMessageRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyMessageRequest create() => VerifyMessageRequest._();
  VerifyMessageRequest createEmptyInstance() => create();
  static $pb.PbList<VerifyMessageRequest> createRepeated() => $pb.PbList<VerifyMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyMessageRequest>(create);
  static VerifyMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get signature => $_getSZ(2);
  @$pb.TagNumber(3)
  set signature($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get publicKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicKey($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicKey() => clearField(4);
}

class VerifyMessageResponse extends $pb.GeneratedMessage {
  factory VerifyMessageResponse({
    $core.bool? valid,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    return $result;
  }
  VerifyMessageResponse._() : super();
  factory VerifyMessageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyMessageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyMessageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyMessageResponse clone() => VerifyMessageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyMessageResponse copyWith(void Function(VerifyMessageResponse) updates) => super.copyWith((message) => updates(message as VerifyMessageResponse)) as VerifyMessageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyMessageResponse create() => VerifyMessageResponse._();
  VerifyMessageResponse createEmptyInstance() => create();
  static $pb.PbList<VerifyMessageResponse> createRepeated() => $pb.PbList<VerifyMessageResponse>();
  @$core.pragma('dart2js:noInline')
  static VerifyMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyMessageResponse>(create);
  static VerifyMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);
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
    final $result = create();
    if (utxosCurrent != null) {
      $result.utxosCurrent = utxosCurrent;
    }
    if (utxosUniqueAddresses != null) {
      $result.utxosUniqueAddresses = utxosUniqueAddresses;
    }
    if (sidechainDepositVolume != null) {
      $result.sidechainDepositVolume = sidechainDepositVolume;
    }
    if (sidechainDepositVolumeLast30Days != null) {
      $result.sidechainDepositVolumeLast30Days = sidechainDepositVolumeLast30Days;
    }
    if (transactionCountTotal != null) {
      $result.transactionCountTotal = transactionCountTotal;
    }
    if (transactionCountSinceMonth != null) {
      $result.transactionCountSinceMonth = transactionCountSinceMonth;
    }
    return $result;
  }
  GetStatsResponse._() : super();
  factory GetStatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'utxosCurrent', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'utxosUniqueAddresses', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'sidechainDepositVolume')
    ..aInt64(4, _omitFieldNames ? '' : 'sidechainDepositVolumeLast30Days', protoName: 'sidechain_deposit_volume_last_30_days')
    ..aInt64(5, _omitFieldNames ? '' : 'transactionCountTotal')
    ..aInt64(6, _omitFieldNames ? '' : 'transactionCountSinceMonth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStatsResponse clone() => GetStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStatsResponse copyWith(void Function(GetStatsResponse) updates) => super.copyWith((message) => updates(message as GetStatsResponse)) as GetStatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsResponse create() => GetStatsResponse._();
  GetStatsResponse createEmptyInstance() => create();
  static $pb.PbList<GetStatsResponse> createRepeated() => $pb.PbList<GetStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsResponse>(create);
  static GetStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get utxosCurrent => $_getI64(0);
  @$pb.TagNumber(1)
  set utxosCurrent($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtxosCurrent() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtxosCurrent() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get utxosUniqueAddresses => $_getI64(1);
  @$pb.TagNumber(2)
  set utxosUniqueAddresses($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUtxosUniqueAddresses() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxosUniqueAddresses() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sidechainDepositVolume => $_getI64(2);
  @$pb.TagNumber(3)
  set sidechainDepositVolume($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSidechainDepositVolume() => $_has(2);
  @$pb.TagNumber(3)
  void clearSidechainDepositVolume() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sidechainDepositVolumeLast30Days => $_getI64(3);
  @$pb.TagNumber(4)
  set sidechainDepositVolumeLast30Days($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSidechainDepositVolumeLast30Days() => $_has(3);
  @$pb.TagNumber(4)
  void clearSidechainDepositVolumeLast30Days() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get transactionCountTotal => $_getI64(4);
  @$pb.TagNumber(5)
  set transactionCountTotal($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTransactionCountTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearTransactionCountTotal() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get transactionCountSinceMonth => $_getI64(5);
  @$pb.TagNumber(6)
  set transactionCountSinceMonth($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTransactionCountSinceMonth() => $_has(5);
  @$pb.TagNumber(6)
  void clearTransactionCountSinceMonth() => clearField(6);
}

/// Wallet unlock/lock messages
class UnlockWalletRequest extends $pb.GeneratedMessage {
  factory UnlockWalletRequest({
    $core.String? password,
  }) {
    final $result = create();
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  UnlockWalletRequest._() : super();
  factory UnlockWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnlockWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnlockWalletRequest clone() => UnlockWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnlockWalletRequest copyWith(void Function(UnlockWalletRequest) updates) => super.copyWith((message) => updates(message as UnlockWalletRequest)) as UnlockWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest create() => UnlockWalletRequest._();
  UnlockWalletRequest createEmptyInstance() => create();
  static $pb.PbList<UnlockWalletRequest> createRepeated() => $pb.PbList<UnlockWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletRequest>(create);
  static UnlockWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => clearField(1);
}

/// Cheque messages
class CreateChequeRequest extends $pb.GeneratedMessage {
  factory CreateChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? expectedAmountSats,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (expectedAmountSats != null) {
      $result.expectedAmountSats = expectedAmountSats;
    }
    return $result;
  }
  CreateChequeRequest._() : super();
  factory CreateChequeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateChequeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChequeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateChequeRequest clone() => CreateChequeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateChequeRequest copyWith(void Function(CreateChequeRequest) updates) => super.copyWith((message) => updates(message as CreateChequeRequest)) as CreateChequeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChequeRequest create() => CreateChequeRequest._();
  CreateChequeRequest createEmptyInstance() => create();
  static $pb.PbList<CreateChequeRequest> createRepeated() => $pb.PbList<CreateChequeRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateChequeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateChequeRequest>(create);
  static CreateChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedAmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedAmountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExpectedAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedAmountSats() => clearField(2);
}

class CreateChequeResponse extends $pb.GeneratedMessage {
  factory CreateChequeResponse({
    $fixnum.Int64? id,
    $core.String? address,
    $core.int? derivationIndex,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (address != null) {
      $result.address = address;
    }
    if (derivationIndex != null) {
      $result.derivationIndex = derivationIndex;
    }
    return $result;
  }
  CreateChequeResponse._() : super();
  factory CreateChequeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateChequeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChequeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'derivationIndex', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateChequeResponse clone() => CreateChequeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateChequeResponse copyWith(void Function(CreateChequeResponse) updates) => super.copyWith((message) => updates(message as CreateChequeResponse)) as CreateChequeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChequeResponse create() => CreateChequeResponse._();
  CreateChequeResponse createEmptyInstance() => create();
  static $pb.PbList<CreateChequeResponse> createRepeated() => $pb.PbList<CreateChequeResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateChequeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateChequeResponse>(create);
  static CreateChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get derivationIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set derivationIndex($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDerivationIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationIndex() => clearField(3);
}

class GetChequeRequest extends $pb.GeneratedMessage {
  factory GetChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetChequeRequest._() : super();
  factory GetChequeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChequeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChequeRequest clone() => GetChequeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChequeRequest copyWith(void Function(GetChequeRequest) updates) => super.copyWith((message) => updates(message as GetChequeRequest)) as GetChequeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequeRequest create() => GetChequeRequest._();
  GetChequeRequest createEmptyInstance() => create();
  static $pb.PbList<GetChequeRequest> createRepeated() => $pb.PbList<GetChequeRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChequeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequeRequest>(create);
  static GetChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);
}

class GetChequeResponse extends $pb.GeneratedMessage {
  factory GetChequeResponse({
    Cheque? cheque,
  }) {
    final $result = create();
    if (cheque != null) {
      $result.cheque = cheque;
    }
    return $result;
  }
  GetChequeResponse._() : super();
  factory GetChequeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChequeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOM<Cheque>(1, _omitFieldNames ? '' : 'cheque', subBuilder: Cheque.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChequeResponse clone() => GetChequeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChequeResponse copyWith(void Function(GetChequeResponse) updates) => super.copyWith((message) => updates(message as GetChequeResponse)) as GetChequeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequeResponse create() => GetChequeResponse._();
  GetChequeResponse createEmptyInstance() => create();
  static $pb.PbList<GetChequeResponse> createRepeated() => $pb.PbList<GetChequeResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChequeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequeResponse>(create);
  static GetChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Cheque get cheque => $_getN(0);
  @$pb.TagNumber(1)
  set cheque(Cheque v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCheque() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheque() => clearField(1);
  @$pb.TagNumber(1)
  Cheque ensureCheque() => $_ensure(0);
}

class GetChequePrivateKeyRequest extends $pb.GeneratedMessage {
  factory GetChequePrivateKeyRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetChequePrivateKeyRequest._() : super();
  factory GetChequePrivateKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChequePrivateKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequePrivateKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChequePrivateKeyRequest clone() => GetChequePrivateKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChequePrivateKeyRequest copyWith(void Function(GetChequePrivateKeyRequest) updates) => super.copyWith((message) => updates(message as GetChequePrivateKeyRequest)) as GetChequePrivateKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyRequest create() => GetChequePrivateKeyRequest._();
  GetChequePrivateKeyRequest createEmptyInstance() => create();
  static $pb.PbList<GetChequePrivateKeyRequest> createRepeated() => $pb.PbList<GetChequePrivateKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyRequest>(create);
  static GetChequePrivateKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);
}

class GetChequePrivateKeyResponse extends $pb.GeneratedMessage {
  factory GetChequePrivateKeyResponse({
    $core.String? privateKeyWif,
  }) {
    final $result = create();
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    return $result;
  }
  GetChequePrivateKeyResponse._() : super();
  factory GetChequePrivateKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChequePrivateKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChequePrivateKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChequePrivateKeyResponse clone() => GetChequePrivateKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChequePrivateKeyResponse copyWith(void Function(GetChequePrivateKeyResponse) updates) => super.copyWith((message) => updates(message as GetChequePrivateKeyResponse)) as GetChequePrivateKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyResponse create() => GetChequePrivateKeyResponse._();
  GetChequePrivateKeyResponse createEmptyInstance() => create();
  static $pb.PbList<GetChequePrivateKeyResponse> createRepeated() => $pb.PbList<GetChequePrivateKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChequePrivateKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChequePrivateKeyResponse>(create);
  static GetChequePrivateKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyWif => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyWif($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyWif() => clearField(1);
}

class Cheque extends $pb.GeneratedMessage {
  factory Cheque({
    $fixnum.Int64? id,
    $core.int? derivationIndex,
    $core.String? address,
    $fixnum.Int64? expectedAmountSats,
    $core.bool? funded,
    $core.String? fundedTxid,
    $fixnum.Int64? actualAmountSats,
    $0.Timestamp? createdAt,
    $0.Timestamp? fundedAt,
    $core.String? privateKeyWif,
    $core.String? sweptTxid,
    $0.Timestamp? sweptAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (derivationIndex != null) {
      $result.derivationIndex = derivationIndex;
    }
    if (address != null) {
      $result.address = address;
    }
    if (expectedAmountSats != null) {
      $result.expectedAmountSats = expectedAmountSats;
    }
    if (funded != null) {
      $result.funded = funded;
    }
    if (fundedTxid != null) {
      $result.fundedTxid = fundedTxid;
    }
    if (actualAmountSats != null) {
      $result.actualAmountSats = actualAmountSats;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (fundedAt != null) {
      $result.fundedAt = fundedAt;
    }
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    if (sweptTxid != null) {
      $result.sweptTxid = sweptTxid;
    }
    if (sweptAt != null) {
      $result.sweptAt = sweptAt;
    }
    return $result;
  }
  Cheque._() : super();
  factory Cheque.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Cheque.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Cheque', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'derivationIndex', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'expectedAmountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'funded')
    ..aOS(6, _omitFieldNames ? '' : 'fundedTxid')
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'fundedAt', subBuilder: $0.Timestamp.create)
    ..aOS(10, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(11, _omitFieldNames ? '' : 'sweptTxid')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'sweptAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Cheque clone() => Cheque()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Cheque copyWith(void Function(Cheque) updates) => super.copyWith((message) => updates(message as Cheque)) as Cheque;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cheque create() => Cheque._();
  Cheque createEmptyInstance() => create();
  static $pb.PbList<Cheque> createRepeated() => $pb.PbList<Cheque>();
  @$core.pragma('dart2js:noInline')
  static Cheque getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cheque>(create);
  static Cheque? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get derivationIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set derivationIndex($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDerivationIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expectedAmountSats => $_getI64(3);
  @$pb.TagNumber(4)
  set expectedAmountSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExpectedAmountSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedAmountSats() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get funded => $_getBF(4);
  @$pb.TagNumber(5)
  set funded($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFunded() => $_has(4);
  @$pb.TagNumber(5)
  void clearFunded() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get fundedTxid => $_getSZ(5);
  @$pb.TagNumber(6)
  set fundedTxid($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFundedTxid() => $_has(5);
  @$pb.TagNumber(6)
  void clearFundedTxid() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get actualAmountSats => $_getI64(6);
  @$pb.TagNumber(7)
  set actualAmountSats($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasActualAmountSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearActualAmountSats() => clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get fundedAt => $_getN(8);
  @$pb.TagNumber(9)
  set fundedAt($0.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasFundedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearFundedAt() => clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureFundedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get privateKeyWif => $_getSZ(9);
  @$pb.TagNumber(10)
  set privateKeyWif($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasPrivateKeyWif() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrivateKeyWif() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get sweptTxid => $_getSZ(10);
  @$pb.TagNumber(11)
  set sweptTxid($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSweptTxid() => $_has(10);
  @$pb.TagNumber(11)
  void clearSweptTxid() => clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get sweptAt => $_getN(11);
  @$pb.TagNumber(12)
  set sweptAt($0.Timestamp v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasSweptAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearSweptAt() => clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureSweptAt() => $_ensure(11);
}

class ListChequesRequest extends $pb.GeneratedMessage {
  factory ListChequesRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListChequesRequest._() : super();
  factory ListChequesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListChequesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListChequesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListChequesRequest clone() => ListChequesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListChequesRequest copyWith(void Function(ListChequesRequest) updates) => super.copyWith((message) => updates(message as ListChequesRequest)) as ListChequesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListChequesRequest create() => ListChequesRequest._();
  ListChequesRequest createEmptyInstance() => create();
  static $pb.PbList<ListChequesRequest> createRepeated() => $pb.PbList<ListChequesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListChequesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListChequesRequest>(create);
  static ListChequesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class ListChequesResponse extends $pb.GeneratedMessage {
  factory ListChequesResponse({
    $core.Iterable<Cheque>? cheques,
  }) {
    final $result = create();
    if (cheques != null) {
      $result.cheques.addAll(cheques);
    }
    return $result;
  }
  ListChequesResponse._() : super();
  factory ListChequesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListChequesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListChequesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<Cheque>(1, _omitFieldNames ? '' : 'cheques', $pb.PbFieldType.PM, subBuilder: Cheque.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListChequesResponse clone() => ListChequesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListChequesResponse copyWith(void Function(ListChequesResponse) updates) => super.copyWith((message) => updates(message as ListChequesResponse)) as ListChequesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListChequesResponse create() => ListChequesResponse._();
  ListChequesResponse createEmptyInstance() => create();
  static $pb.PbList<ListChequesResponse> createRepeated() => $pb.PbList<ListChequesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListChequesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListChequesResponse>(create);
  static ListChequesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Cheque> get cheques => $_getList(0);
}

class CheckChequeFundingRequest extends $pb.GeneratedMessage {
  factory CheckChequeFundingRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CheckChequeFundingRequest._() : super();
  factory CheckChequeFundingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckChequeFundingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckChequeFundingRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckChequeFundingRequest clone() => CheckChequeFundingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckChequeFundingRequest copyWith(void Function(CheckChequeFundingRequest) updates) => super.copyWith((message) => updates(message as CheckChequeFundingRequest)) as CheckChequeFundingRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingRequest create() => CheckChequeFundingRequest._();
  CheckChequeFundingRequest createEmptyInstance() => create();
  static $pb.PbList<CheckChequeFundingRequest> createRepeated() => $pb.PbList<CheckChequeFundingRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingRequest>(create);
  static CheckChequeFundingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);
}

class CheckChequeFundingResponse extends $pb.GeneratedMessage {
  factory CheckChequeFundingResponse({
    $core.bool? funded,
    $fixnum.Int64? actualAmountSats,
    $core.String? fundedTxid,
    $0.Timestamp? fundedAt,
  }) {
    final $result = create();
    if (funded != null) {
      $result.funded = funded;
    }
    if (actualAmountSats != null) {
      $result.actualAmountSats = actualAmountSats;
    }
    if (fundedTxid != null) {
      $result.fundedTxid = fundedTxid;
    }
    if (fundedAt != null) {
      $result.fundedAt = fundedAt;
    }
    return $result;
  }
  CheckChequeFundingResponse._() : super();
  factory CheckChequeFundingResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckChequeFundingResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckChequeFundingResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'funded')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'actualAmountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'fundedTxid')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'fundedAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckChequeFundingResponse clone() => CheckChequeFundingResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckChequeFundingResponse copyWith(void Function(CheckChequeFundingResponse) updates) => super.copyWith((message) => updates(message as CheckChequeFundingResponse)) as CheckChequeFundingResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingResponse create() => CheckChequeFundingResponse._();
  CheckChequeFundingResponse createEmptyInstance() => create();
  static $pb.PbList<CheckChequeFundingResponse> createRepeated() => $pb.PbList<CheckChequeFundingResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckChequeFundingResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckChequeFundingResponse>(create);
  static CheckChequeFundingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get funded => $_getBF(0);
  @$pb.TagNumber(1)
  set funded($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFunded() => $_has(0);
  @$pb.TagNumber(1)
  void clearFunded() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get actualAmountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set actualAmountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActualAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearActualAmountSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fundedTxid => $_getSZ(2);
  @$pb.TagNumber(3)
  set fundedTxid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFundedTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFundedTxid() => clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get fundedAt => $_getN(3);
  @$pb.TagNumber(4)
  set fundedAt($0.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFundedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearFundedAt() => clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureFundedAt() => $_ensure(3);
}

class SweepChequeRequest extends $pb.GeneratedMessage {
  factory SweepChequeRequest({
    $core.String? walletId,
    $core.String? privateKeyWif,
    $core.String? destinationAddress,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    if (destinationAddress != null) {
      $result.destinationAddress = destinationAddress;
    }
    if (feeSatPerVbyte != null) {
      $result.feeSatPerVbyte = feeSatPerVbyte;
    }
    return $result;
  }
  SweepChequeRequest._() : super();
  factory SweepChequeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SweepChequeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SweepChequeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(3, _omitFieldNames ? '' : 'destinationAddress')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SweepChequeRequest clone() => SweepChequeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SweepChequeRequest copyWith(void Function(SweepChequeRequest) updates) => super.copyWith((message) => updates(message as SweepChequeRequest)) as SweepChequeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SweepChequeRequest create() => SweepChequeRequest._();
  SweepChequeRequest createEmptyInstance() => create();
  static $pb.PbList<SweepChequeRequest> createRepeated() => $pb.PbList<SweepChequeRequest>();
  @$core.pragma('dart2js:noInline')
  static SweepChequeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SweepChequeRequest>(create);
  static SweepChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get destinationAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set destinationAddress($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDestinationAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestinationAddress() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSatPerVbyte() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSatPerVbyte() => clearField(4);
}

class SweepChequeResponse extends $pb.GeneratedMessage {
  factory SweepChequeResponse({
    $core.String? txid,
    $fixnum.Int64? amountSats,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    return $result;
  }
  SweepChequeResponse._() : super();
  factory SweepChequeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SweepChequeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SweepChequeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SweepChequeResponse clone() => SweepChequeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SweepChequeResponse copyWith(void Function(SweepChequeResponse) updates) => super.copyWith((message) => updates(message as SweepChequeResponse)) as SweepChequeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SweepChequeResponse create() => SweepChequeResponse._();
  SweepChequeResponse createEmptyInstance() => create();
  static $pb.PbList<SweepChequeResponse> createRepeated() => $pb.PbList<SweepChequeResponse>();
  @$core.pragma('dart2js:noInline')
  static SweepChequeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SweepChequeResponse>(create);
  static SweepChequeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => clearField(2);
}

class DeleteChequeRequest extends $pb.GeneratedMessage {
  factory DeleteChequeRequest({
    $core.String? walletId,
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteChequeRequest._() : super();
  factory DeleteChequeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteChequeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteChequeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteChequeRequest clone() => DeleteChequeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteChequeRequest copyWith(void Function(DeleteChequeRequest) updates) => super.copyWith((message) => updates(message as DeleteChequeRequest)) as DeleteChequeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteChequeRequest create() => DeleteChequeRequest._();
  DeleteChequeRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteChequeRequest> createRepeated() => $pb.PbList<DeleteChequeRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteChequeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteChequeRequest>(create);
  static DeleteChequeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);
}

class CreateBitcoinCoreWalletRequest extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletRequest({
    $core.String? seedHex,
    $core.String? name,
  }) {
    final $result = create();
    if (seedHex != null) {
      $result.seedHex = seedHex;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  CreateBitcoinCoreWalletRequest._() : super();
  factory CreateBitcoinCoreWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBitcoinCoreWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'seedHex')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletRequest clone() => CreateBitcoinCoreWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletRequest copyWith(void Function(CreateBitcoinCoreWalletRequest) updates) => super.copyWith((message) => updates(message as CreateBitcoinCoreWalletRequest)) as CreateBitcoinCoreWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest create() => CreateBitcoinCoreWalletRequest._();
  CreateBitcoinCoreWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateBitcoinCoreWalletRequest> createRepeated() => $pb.PbList<CreateBitcoinCoreWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletRequest>(create);
  static CreateBitcoinCoreWalletRequest? _defaultInstance;

  /// BIP32 seed as hex string (64 bytes = 128 hex chars)
  /// This is the output of BIP39 PBKDF2(mnemonic + passphrase)
  @$pb.TagNumber(1)
  $core.String get seedHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set seedHex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSeedHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeedHex() => clearField(1);

  /// Wallet name for display
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class CreateBitcoinCoreWalletResponse extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletResponse({
    $core.String? walletId,
    $core.String? coreWalletName,
    $core.String? firstAddress,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (coreWalletName != null) {
      $result.coreWalletName = coreWalletName;
    }
    if (firstAddress != null) {
      $result.firstAddress = firstAddress;
    }
    return $result;
  }
  CreateBitcoinCoreWalletResponse._() : super();
  factory CreateBitcoinCoreWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBitcoinCoreWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'coreWalletName')
    ..aOS(3, _omitFieldNames ? '' : 'firstAddress')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletResponse clone() => CreateBitcoinCoreWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletResponse copyWith(void Function(CreateBitcoinCoreWalletResponse) updates) => super.copyWith((message) => updates(message as CreateBitcoinCoreWalletResponse)) as CreateBitcoinCoreWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse create() => CreateBitcoinCoreWalletResponse._();
  CreateBitcoinCoreWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateBitcoinCoreWalletResponse> createRepeated() => $pb.PbList<CreateBitcoinCoreWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletResponse>(create);
  static CreateBitcoinCoreWalletResponse? _defaultInstance;

  /// The wallet ID that was created
  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  /// The Bitcoin Core wallet name
  @$pb.TagNumber(2)
  $core.String get coreWalletName => $_getSZ(1);
  @$pb.TagNumber(2)
  set coreWalletName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCoreWalletName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoreWalletName() => clearField(2);

  /// First receiving address for verification
  @$pb.TagNumber(3)
  $core.String get firstAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set firstAddress($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFirstAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearFirstAddress() => clearField(3);
}

/// UTXO Coin Control metadata
class UTXOMetadata extends $pb.GeneratedMessage {
  factory UTXOMetadata({
    $core.String? outpoint,
    $core.bool? isFrozen_2,
    $core.String? label,
  }) {
    final $result = create();
    if (outpoint != null) {
      $result.outpoint = outpoint;
    }
    if (isFrozen_2 != null) {
      $result.isFrozen_2 = isFrozen_2;
    }
    if (label != null) {
      $result.label = label;
    }
    return $result;
  }
  UTXOMetadata._() : super();
  factory UTXOMetadata.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UTXOMetadata.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UTXOMetadata', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UTXOMetadata clone() => UTXOMetadata()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UTXOMetadata copyWith(void Function(UTXOMetadata) updates) => super.copyWith((message) => updates(message as UTXOMetadata)) as UTXOMetadata;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOMetadata create() => UTXOMetadata._();
  UTXOMetadata createEmptyInstance() => create();
  static $pb.PbList<UTXOMetadata> createRepeated() => $pb.PbList<UTXOMetadata>();
  @$core.pragma('dart2js:noInline')
  static UTXOMetadata getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOMetadata>(create);
  static UTXOMetadata? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set outpoint($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOutpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutpoint() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFrozen_2 => $_getBF(1);
  @$pb.TagNumber(2)
  set isFrozen_2($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsFrozen_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFrozen_2() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);
}

class SetUTXOMetadataRequest extends $pb.GeneratedMessage {
  factory SetUTXOMetadataRequest({
    $core.String? outpoint,
    $core.bool? isFrozen_2,
    $core.String? label,
  }) {
    final $result = create();
    if (outpoint != null) {
      $result.outpoint = outpoint;
    }
    if (isFrozen_2 != null) {
      $result.isFrozen_2 = isFrozen_2;
    }
    if (label != null) {
      $result.label = label;
    }
    return $result;
  }
  SetUTXOMetadataRequest._() : super();
  factory SetUTXOMetadataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetUTXOMetadataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetUTXOMetadataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOB(2, _omitFieldNames ? '' : 'isFrozen')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetUTXOMetadataRequest clone() => SetUTXOMetadataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetUTXOMetadataRequest copyWith(void Function(SetUTXOMetadataRequest) updates) => super.copyWith((message) => updates(message as SetUTXOMetadataRequest)) as SetUTXOMetadataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetUTXOMetadataRequest create() => SetUTXOMetadataRequest._();
  SetUTXOMetadataRequest createEmptyInstance() => create();
  static $pb.PbList<SetUTXOMetadataRequest> createRepeated() => $pb.PbList<SetUTXOMetadataRequest>();
  @$core.pragma('dart2js:noInline')
  static SetUTXOMetadataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetUTXOMetadataRequest>(create);
  static SetUTXOMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set outpoint($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOutpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutpoint() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFrozen_2 => $_getBF(1);
  @$pb.TagNumber(2)
  set isFrozen_2($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsFrozen_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFrozen_2() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);
}

class GetUTXOMetadataRequest extends $pb.GeneratedMessage {
  factory GetUTXOMetadataRequest({
    $core.Iterable<$core.String>? outpoints,
  }) {
    final $result = create();
    if (outpoints != null) {
      $result.outpoints.addAll(outpoints);
    }
    return $result;
  }
  GetUTXOMetadataRequest._() : super();
  factory GetUTXOMetadataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUTXOMetadataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXOMetadataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'outpoints')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUTXOMetadataRequest clone() => GetUTXOMetadataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUTXOMetadataRequest copyWith(void Function(GetUTXOMetadataRequest) updates) => super.copyWith((message) => updates(message as GetUTXOMetadataRequest)) as GetUTXOMetadataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataRequest create() => GetUTXOMetadataRequest._();
  GetUTXOMetadataRequest createEmptyInstance() => create();
  static $pb.PbList<GetUTXOMetadataRequest> createRepeated() => $pb.PbList<GetUTXOMetadataRequest>();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataRequest>(create);
  static GetUTXOMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get outpoints => $_getList(0);
}

class GetUTXOMetadataResponse extends $pb.GeneratedMessage {
  factory GetUTXOMetadataResponse({
    $core.Map<$core.String, UTXOMetadata>? metadata,
  }) {
    final $result = create();
    if (metadata != null) {
      $result.metadata.addAll(metadata);
    }
    return $result;
  }
  GetUTXOMetadataResponse._() : super();
  factory GetUTXOMetadataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUTXOMetadataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXOMetadataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..m<$core.String, UTXOMetadata>(1, _omitFieldNames ? '' : 'metadata', entryClassName: 'GetUTXOMetadataResponse.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: UTXOMetadata.create, valueDefaultOrMaker: UTXOMetadata.getDefault, packageName: const $pb.PackageName('wallet.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUTXOMetadataResponse clone() => GetUTXOMetadataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUTXOMetadataResponse copyWith(void Function(GetUTXOMetadataResponse) updates) => super.copyWith((message) => updates(message as GetUTXOMetadataResponse)) as GetUTXOMetadataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataResponse create() => GetUTXOMetadataResponse._();
  GetUTXOMetadataResponse createEmptyInstance() => create();
  static $pb.PbList<GetUTXOMetadataResponse> createRepeated() => $pb.PbList<GetUTXOMetadataResponse>();
  @$core.pragma('dart2js:noInline')
  static GetUTXOMetadataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUTXOMetadataResponse>(create);
  static GetUTXOMetadataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, UTXOMetadata> get metadata => $_getMap(0);
}

class SetCoinSelectionStrategyRequest extends $pb.GeneratedMessage {
  factory SetCoinSelectionStrategyRequest({
    CoinSelectionStrategy? strategy,
  }) {
    final $result = create();
    if (strategy != null) {
      $result.strategy = strategy;
    }
    return $result;
  }
  SetCoinSelectionStrategyRequest._() : super();
  factory SetCoinSelectionStrategyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetCoinSelectionStrategyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetCoinSelectionStrategyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..e<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy', $pb.PbFieldType.OE, defaultOrMaker: CoinSelectionStrategy.COIN_SELECTION_STRATEGY_UNSPECIFIED, valueOf: CoinSelectionStrategy.valueOf, enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetCoinSelectionStrategyRequest clone() => SetCoinSelectionStrategyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetCoinSelectionStrategyRequest copyWith(void Function(SetCoinSelectionStrategyRequest) updates) => super.copyWith((message) => updates(message as SetCoinSelectionStrategyRequest)) as SetCoinSelectionStrategyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCoinSelectionStrategyRequest create() => SetCoinSelectionStrategyRequest._();
  SetCoinSelectionStrategyRequest createEmptyInstance() => create();
  static $pb.PbList<SetCoinSelectionStrategyRequest> createRepeated() => $pb.PbList<SetCoinSelectionStrategyRequest>();
  @$core.pragma('dart2js:noInline')
  static SetCoinSelectionStrategyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetCoinSelectionStrategyRequest>(create);
  static SetCoinSelectionStrategyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CoinSelectionStrategy get strategy => $_getN(0);
  @$pb.TagNumber(1)
  set strategy(CoinSelectionStrategy v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStrategy() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategy() => clearField(1);
}

class GetCoinSelectionStrategyResponse extends $pb.GeneratedMessage {
  factory GetCoinSelectionStrategyResponse({
    CoinSelectionStrategy? strategy,
  }) {
    final $result = create();
    if (strategy != null) {
      $result.strategy = strategy;
    }
    return $result;
  }
  GetCoinSelectionStrategyResponse._() : super();
  factory GetCoinSelectionStrategyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinSelectionStrategyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinSelectionStrategyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..e<CoinSelectionStrategy>(1, _omitFieldNames ? '' : 'strategy', $pb.PbFieldType.OE, defaultOrMaker: CoinSelectionStrategy.COIN_SELECTION_STRATEGY_UNSPECIFIED, valueOf: CoinSelectionStrategy.valueOf, enumValues: CoinSelectionStrategy.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinSelectionStrategyResponse clone() => GetCoinSelectionStrategyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinSelectionStrategyResponse copyWith(void Function(GetCoinSelectionStrategyResponse) updates) => super.copyWith((message) => updates(message as GetCoinSelectionStrategyResponse)) as GetCoinSelectionStrategyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinSelectionStrategyResponse create() => GetCoinSelectionStrategyResponse._();
  GetCoinSelectionStrategyResponse createEmptyInstance() => create();
  static $pb.PbList<GetCoinSelectionStrategyResponse> createRepeated() => $pb.PbList<GetCoinSelectionStrategyResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCoinSelectionStrategyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinSelectionStrategyResponse>(create);
  static GetCoinSelectionStrategyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CoinSelectionStrategy get strategy => $_getN(0);
  @$pb.TagNumber(1)
  set strategy(CoinSelectionStrategy v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStrategy() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategy() => clearField(1);
}

/// Transaction Details - enriched transaction data with resolved inputs
class GetTransactionDetailsRequest extends $pb.GeneratedMessage {
  factory GetTransactionDetailsRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionDetailsRequest._() : super();
  factory GetTransactionDetailsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionDetailsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsRequest clone() => GetTransactionDetailsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsRequest copyWith(void Function(GetTransactionDetailsRequest) updates) => super.copyWith((message) => updates(message as GetTransactionDetailsRequest)) as GetTransactionDetailsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest create() => GetTransactionDetailsRequest._();
  GetTransactionDetailsRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionDetailsRequest> createRepeated() => $pb.PbList<GetTransactionDetailsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsRequest>(create);
  static GetTransactionDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (blockhash != null) {
      $result.blockhash = blockhash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (vsizeVbytes != null) {
      $result.vsizeVbytes = vsizeVbytes;
    }
    if (weightWu != null) {
      $result.weightWu = weightWu;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (feeRateSatVb != null) {
      $result.feeRateSatVb = feeRateSatVb;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (totalInputSats != null) {
      $result.totalInputSats = totalInputSats;
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (totalOutputSats != null) {
      $result.totalOutputSats = totalOutputSats;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  GetTransactionDetailsResponse._() : super();
  factory GetTransactionDetailsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionDetailsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'blockhash')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aInt64(4, _omitFieldNames ? '' : 'blockTime')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'sizeBytes', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'vsizeVbytes', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'weightWu', $pb.PbFieldType.O3)
    ..aInt64(10, _omitFieldNames ? '' : 'feeSats')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'feeRateSatVb', $pb.PbFieldType.OD)
    ..pc<TransactionInput>(12, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TransactionInput.create)
    ..aInt64(13, _omitFieldNames ? '' : 'totalInputSats')
    ..pc<TransactionOutput>(14, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TransactionOutput.create)
    ..aInt64(15, _omitFieldNames ? '' : 'totalOutputSats')
    ..aOS(16, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsResponse clone() => GetTransactionDetailsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsResponse copyWith(void Function(GetTransactionDetailsResponse) updates) => super.copyWith((message) => updates(message as GetTransactionDetailsResponse)) as GetTransactionDetailsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse create() => GetTransactionDetailsResponse._();
  GetTransactionDetailsResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionDetailsResponse> createRepeated() => $pb.PbList<GetTransactionDetailsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsResponse>(create);
  static GetTransactionDetailsResponse? _defaultInstance;

  /// Header info
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockhash => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockhash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockhash() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockhash() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get blockTime => $_getI64(3);
  @$pb.TagNumber(4)
  set blockTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockTime() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get locktime => $_getIZ(5);
  @$pb.TagNumber(6)
  set locktime($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocktime() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocktime() => clearField(6);

  /// Size info
  @$pb.TagNumber(7)
  $core.int get sizeBytes => $_getIZ(6);
  @$pb.TagNumber(7)
  set sizeBytes($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSizeBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearSizeBytes() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get vsizeVbytes => $_getIZ(7);
  @$pb.TagNumber(8)
  set vsizeVbytes($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasVsizeVbytes() => $_has(7);
  @$pb.TagNumber(8)
  void clearVsizeVbytes() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get weightWu => $_getIZ(8);
  @$pb.TagNumber(9)
  set weightWu($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasWeightWu() => $_has(8);
  @$pb.TagNumber(9)
  void clearWeightWu() => clearField(9);

  /// Fee info (computed: sum(inputs) - sum(outputs))
  @$pb.TagNumber(10)
  $fixnum.Int64 get feeSats => $_getI64(9);
  @$pb.TagNumber(10)
  set feeSats($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasFeeSats() => $_has(9);
  @$pb.TagNumber(10)
  void clearFeeSats() => clearField(10);

  @$pb.TagNumber(11)
  $core.double get feeRateSatVb => $_getN(10);
  @$pb.TagNumber(11)
  set feeRateSatVb($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFeeRateSatVb() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeeRateSatVb() => clearField(11);

  /// Enriched inputs (backend resolves address/value from referenced tx)
  @$pb.TagNumber(12)
  $core.List<TransactionInput> get inputs => $_getList(11);

  @$pb.TagNumber(13)
  $fixnum.Int64 get totalInputSats => $_getI64(12);
  @$pb.TagNumber(13)
  set totalInputSats($fixnum.Int64 v) { $_setInt64(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasTotalInputSats() => $_has(12);
  @$pb.TagNumber(13)
  void clearTotalInputSats() => clearField(13);

  /// Outputs
  @$pb.TagNumber(14)
  $core.List<TransactionOutput> get outputs => $_getList(13);

  @$pb.TagNumber(15)
  $fixnum.Int64 get totalOutputSats => $_getI64(14);
  @$pb.TagNumber(15)
  set totalOutputSats($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasTotalOutputSats() => $_has(14);
  @$pb.TagNumber(15)
  void clearTotalOutputSats() => clearField(15);

  /// Raw hex for display
  @$pb.TagNumber(16)
  $core.String get hex => $_getSZ(15);
  @$pb.TagNumber(16)
  set hex($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasHex() => $_has(15);
  @$pb.TagNumber(16)
  void clearHex() => clearField(16);
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
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (prevTxid != null) {
      $result.prevTxid = prevTxid;
    }
    if (prevVout != null) {
      $result.prevVout = prevVout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (scriptSigAsm != null) {
      $result.scriptSigAsm = scriptSigAsm;
    }
    if (scriptSigHex != null) {
      $result.scriptSigHex = scriptSigHex;
    }
    if (witness != null) {
      $result.witness.addAll(witness);
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (isCoinbase != null) {
      $result.isCoinbase = isCoinbase;
    }
    return $result;
  }
  TransactionInput._() : super();
  factory TransactionInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'prevTxid')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'prevVout', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'address')
    ..aInt64(5, _omitFieldNames ? '' : 'valueSats')
    ..aOS(6, _omitFieldNames ? '' : 'scriptSigAsm')
    ..aOS(7, _omitFieldNames ? '' : 'scriptSigHex')
    ..pPS(8, _omitFieldNames ? '' : 'witness')
    ..aInt64(9, _omitFieldNames ? '' : 'sequence')
    ..aOB(10, _omitFieldNames ? '' : 'isCoinbase')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionInput clone() => TransactionInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionInput copyWith(void Function(TransactionInput) updates) => super.copyWith((message) => updates(message as TransactionInput)) as TransactionInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionInput create() => TransactionInput._();
  TransactionInput createEmptyInstance() => create();
  static $pb.PbList<TransactionInput> createRepeated() => $pb.PbList<TransactionInput>();
  @$core.pragma('dart2js:noInline')
  static TransactionInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionInput>(create);
  static TransactionInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevTxid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevTxid() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get prevVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set prevVout($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevVout() => clearField(3);

  /// These require backend to fetch the referenced transaction
  @$pb.TagNumber(4)
  $core.String get address => $_getSZ(3);
  @$pb.TagNumber(4)
  set address($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddress() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get valueSats => $_getI64(4);
  @$pb.TagNumber(5)
  set valueSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValueSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueSats() => clearField(5);

  /// Script data
  @$pb.TagNumber(6)
  $core.String get scriptSigAsm => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptSigAsm($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptSigAsm() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptSigAsm() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get scriptSigHex => $_getSZ(6);
  @$pb.TagNumber(7)
  set scriptSigHex($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasScriptSigHex() => $_has(6);
  @$pb.TagNumber(7)
  void clearScriptSigHex() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get witness => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get sequence => $_getI64(8);
  @$pb.TagNumber(9)
  set sequence($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSequence() => $_has(8);
  @$pb.TagNumber(9)
  void clearSequence() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isCoinbase => $_getBF(9);
  @$pb.TagNumber(10)
  set isCoinbase($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsCoinbase() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsCoinbase() => clearField(10);
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
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (address != null) {
      $result.address = address;
    }
    if (scriptType != null) {
      $result.scriptType = scriptType;
    }
    if (scriptPubkeyAsm != null) {
      $result.scriptPubkeyAsm = scriptPubkeyAsm;
    }
    if (scriptPubkeyHex != null) {
      $result.scriptPubkeyHex = scriptPubkeyHex;
    }
    return $result;
  }
  TransactionOutput._() : super();
  factory TransactionOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'scriptType')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubkeyAsm')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionOutput clone() => TransactionOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionOutput copyWith(void Function(TransactionOutput) updates) => super.copyWith((message) => updates(message as TransactionOutput)) as TransactionOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionOutput create() => TransactionOutput._();
  TransactionOutput createEmptyInstance() => create();
  static $pb.PbList<TransactionOutput> createRepeated() => $pb.PbList<TransactionOutput>();
  @$core.pragma('dart2js:noInline')
  static TransactionOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionOutput>(create);
  static TransactionOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get scriptType => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get scriptPubkeyAsm => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptPubkeyAsm($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScriptPubkeyAsm() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptPubkeyAsm() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkeyHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkeyHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkeyHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkeyHex() => clearField(6);
}

/// UTXO Distribution - for chart visualization
class GetUTXODistributionRequest extends $pb.GeneratedMessage {
  factory GetUTXODistributionRequest({
    $core.String? walletId,
    $core.int? maxBuckets,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (maxBuckets != null) {
      $result.maxBuckets = maxBuckets;
    }
    return $result;
  }
  GetUTXODistributionRequest._() : super();
  factory GetUTXODistributionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUTXODistributionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXODistributionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'maxBuckets', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUTXODistributionRequest clone() => GetUTXODistributionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUTXODistributionRequest copyWith(void Function(GetUTXODistributionRequest) updates) => super.copyWith((message) => updates(message as GetUTXODistributionRequest)) as GetUTXODistributionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionRequest create() => GetUTXODistributionRequest._();
  GetUTXODistributionRequest createEmptyInstance() => create();
  static $pb.PbList<GetUTXODistributionRequest> createRepeated() => $pb.PbList<GetUTXODistributionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionRequest>(create);
  static GetUTXODistributionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxBuckets => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxBuckets($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxBuckets() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxBuckets() => clearField(2);
}

class GetUTXODistributionResponse extends $pb.GeneratedMessage {
  factory GetUTXODistributionResponse({
    $core.Iterable<UTXOBucket>? buckets,
  }) {
    final $result = create();
    if (buckets != null) {
      $result.buckets.addAll(buckets);
    }
    return $result;
  }
  GetUTXODistributionResponse._() : super();
  factory GetUTXODistributionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUTXODistributionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUTXODistributionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..pc<UTXOBucket>(1, _omitFieldNames ? '' : 'buckets', $pb.PbFieldType.PM, subBuilder: UTXOBucket.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUTXODistributionResponse clone() => GetUTXODistributionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUTXODistributionResponse copyWith(void Function(GetUTXODistributionResponse) updates) => super.copyWith((message) => updates(message as GetUTXODistributionResponse)) as GetUTXODistributionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionResponse create() => GetUTXODistributionResponse._();
  GetUTXODistributionResponse createEmptyInstance() => create();
  static $pb.PbList<GetUTXODistributionResponse> createRepeated() => $pb.PbList<GetUTXODistributionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetUTXODistributionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUTXODistributionResponse>(create);
  static GetUTXODistributionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UTXOBucket> get buckets => $_getList(0);
}

class UTXOBucket extends $pb.GeneratedMessage {
  factory UTXOBucket({
    $core.String? label,
    $fixnum.Int64? valueSats,
    $core.int? count,
    $core.Iterable<$core.String>? outpoints,
  }) {
    final $result = create();
    if (label != null) {
      $result.label = label;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (count != null) {
      $result.count = count;
    }
    if (outpoints != null) {
      $result.outpoints.addAll(outpoints);
    }
    return $result;
  }
  UTXOBucket._() : super();
  factory UTXOBucket.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UTXOBucket.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UTXOBucket', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..pPS(4, _omitFieldNames ? '' : 'outpoints')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UTXOBucket clone() => UTXOBucket()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UTXOBucket copyWith(void Function(UTXOBucket) updates) => super.copyWith((message) => updates(message as UTXOBucket)) as UTXOBucket;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOBucket create() => UTXOBucket._();
  UTXOBucket createEmptyInstance() => create();
  static $pb.PbList<UTXOBucket> createRepeated() => $pb.PbList<UTXOBucket>();
  @$core.pragma('dart2js:noInline')
  static UTXOBucket getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOBucket>(create);
  static UTXOBucket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get outpoints => $_getList(3);
}

class WalletServiceApi {
  $pb.RpcClient _client;
  WalletServiceApi(this._client);

  $async.Future<CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ClientContext? ctx, CreateBitcoinCoreWalletRequest request) =>
    _client.invoke<CreateBitcoinCoreWalletResponse>(ctx, 'WalletService', 'CreateBitcoinCoreWallet', request, CreateBitcoinCoreWalletResponse())
  ;
  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
    _client.invoke<SendTransactionResponse>(ctx, 'WalletService', 'SendTransaction', request, SendTransactionResponse())
  ;
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'WalletService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'WalletService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'WalletService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
    _client.invoke<ListUnspentResponse>(ctx, 'WalletService', 'ListUnspent', request, ListUnspentResponse())
  ;
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses($pb.ClientContext? ctx, ListReceiveAddressesRequest request) =>
    _client.invoke<ListReceiveAddressesResponse>(ctx, 'WalletService', 'ListReceiveAddresses', request, ListReceiveAddressesResponse())
  ;
  $async.Future<ListSidechainDepositsResponse> listSidechainDeposits($pb.ClientContext? ctx, ListSidechainDepositsRequest request) =>
    _client.invoke<ListSidechainDepositsResponse>(ctx, 'WalletService', 'ListSidechainDeposits', request, ListSidechainDepositsResponse())
  ;
  $async.Future<CreateSidechainDepositResponse> createSidechainDeposit($pb.ClientContext? ctx, CreateSidechainDepositRequest request) =>
    _client.invoke<CreateSidechainDepositResponse>(ctx, 'WalletService', 'CreateSidechainDeposit', request, CreateSidechainDepositResponse())
  ;
  $async.Future<SignMessageResponse> signMessage($pb.ClientContext? ctx, SignMessageRequest request) =>
    _client.invoke<SignMessageResponse>(ctx, 'WalletService', 'SignMessage', request, SignMessageResponse())
  ;
  $async.Future<VerifyMessageResponse> verifyMessage($pb.ClientContext? ctx, VerifyMessageRequest request) =>
    _client.invoke<VerifyMessageResponse>(ctx, 'WalletService', 'VerifyMessage', request, VerifyMessageResponse())
  ;
  $async.Future<GetStatsResponse> getStats($pb.ClientContext? ctx, GetStatsRequest request) =>
    _client.invoke<GetStatsResponse>(ctx, 'WalletService', 'GetStats', request, GetStatsResponse())
  ;
  $async.Future<$1.Empty> unlockWallet($pb.ClientContext? ctx, UnlockWalletRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'UnlockWallet', request, $1.Empty())
  ;
  $async.Future<$1.Empty> lockWallet($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'LockWallet', request, $1.Empty())
  ;
  $async.Future<$1.Empty> isWalletUnlocked($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'IsWalletUnlocked', request, $1.Empty())
  ;
  $async.Future<CreateChequeResponse> createCheque($pb.ClientContext? ctx, CreateChequeRequest request) =>
    _client.invoke<CreateChequeResponse>(ctx, 'WalletService', 'CreateCheque', request, CreateChequeResponse())
  ;
  $async.Future<GetChequeResponse> getCheque($pb.ClientContext? ctx, GetChequeRequest request) =>
    _client.invoke<GetChequeResponse>(ctx, 'WalletService', 'GetCheque', request, GetChequeResponse())
  ;
  $async.Future<GetChequePrivateKeyResponse> getChequePrivateKey($pb.ClientContext? ctx, GetChequePrivateKeyRequest request) =>
    _client.invoke<GetChequePrivateKeyResponse>(ctx, 'WalletService', 'GetChequePrivateKey', request, GetChequePrivateKeyResponse())
  ;
  $async.Future<ListChequesResponse> listCheques($pb.ClientContext? ctx, ListChequesRequest request) =>
    _client.invoke<ListChequesResponse>(ctx, 'WalletService', 'ListCheques', request, ListChequesResponse())
  ;
  $async.Future<CheckChequeFundingResponse> checkChequeFunding($pb.ClientContext? ctx, CheckChequeFundingRequest request) =>
    _client.invoke<CheckChequeFundingResponse>(ctx, 'WalletService', 'CheckChequeFunding', request, CheckChequeFundingResponse())
  ;
  $async.Future<SweepChequeResponse> sweepCheque($pb.ClientContext? ctx, SweepChequeRequest request) =>
    _client.invoke<SweepChequeResponse>(ctx, 'WalletService', 'SweepCheque', request, SweepChequeResponse())
  ;
  $async.Future<$1.Empty> deleteCheque($pb.ClientContext? ctx, DeleteChequeRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'DeleteCheque', request, $1.Empty())
  ;
  $async.Future<$1.Empty> setUTXOMetadata($pb.ClientContext? ctx, SetUTXOMetadataRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'SetUTXOMetadata', request, $1.Empty())
  ;
  $async.Future<GetUTXOMetadataResponse> getUTXOMetadata($pb.ClientContext? ctx, GetUTXOMetadataRequest request) =>
    _client.invoke<GetUTXOMetadataResponse>(ctx, 'WalletService', 'GetUTXOMetadata', request, GetUTXOMetadataResponse())
  ;
  $async.Future<$1.Empty> setCoinSelectionStrategy($pb.ClientContext? ctx, SetCoinSelectionStrategyRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletService', 'SetCoinSelectionStrategy', request, $1.Empty())
  ;
  $async.Future<GetCoinSelectionStrategyResponse> getCoinSelectionStrategy($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetCoinSelectionStrategyResponse>(ctx, 'WalletService', 'GetCoinSelectionStrategy', request, GetCoinSelectionStrategyResponse())
  ;
  $async.Future<GetTransactionDetailsResponse> getTransactionDetails($pb.ClientContext? ctx, GetTransactionDetailsRequest request) =>
    _client.invoke<GetTransactionDetailsResponse>(ctx, 'WalletService', 'GetTransactionDetails', request, GetTransactionDetailsResponse())
  ;
  $async.Future<GetUTXODistributionResponse> getUTXODistribution($pb.ClientContext? ctx, GetUTXODistributionRequest request) =>
    _client.invoke<GetUTXODistributionResponse>(ctx, 'WalletService', 'GetUTXODistribution', request, GetUTXODistributionResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
