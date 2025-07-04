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

import '../../bitwindowd/v1/bitwindowd.pb.dart' as $3;
import '../../google/protobuf/empty.pb.dart' as $1;
import '../../google/protobuf/timestamp.pb.dart' as $0;

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

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.Map<$core.String, $fixnum.Int64>? destinations,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? fixedFeeSats,
    $core.String? opReturnMessage,
    $core.String? label,
    $core.Iterable<UnspentOutput>? requiredInputs,
  }) {
    final $result = create();
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
    ..m<$core.String, $fixnum.Int64>(1, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendTransactionRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OU6, packageName: const $pb.PackageName('wallet.v1'))
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'fixedFeeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'opReturnMessage')
    ..aOS(5, _omitFieldNames ? '' : 'label')
    ..pc<UnspentOutput>(6, _omitFieldNames ? '' : 'requiredInputs', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
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

  /// Map of destination address to amount in satoshi.
  @$pb.TagNumber(1)
  $core.Map<$core.String, $fixnum.Int64> get destinations => $_getMap(0);

  /// Fee rate, measured in sat/vb. If set to zero, a reasonable
  /// rate is used by asking Core for an estimate.
  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSatPerVbyte() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSatPerVbyte() => clearField(2);

  /// Hard-coded amount, in sats.
  @$pb.TagNumber(3)
  $fixnum.Int64 get fixedFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set fixedFeeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFixedFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFixedFeeSats() => clearField(3);

  /// Message to include as an OP_RETURN output
  @$pb.TagNumber(4)
  $core.String get opReturnMessage => $_getSZ(3);
  @$pb.TagNumber(4)
  set opReturnMessage($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOpReturnMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearOpReturnMessage() => clearField(4);

  /// If set, will save the address with this label in the address book
  @$pb.TagNumber(5)
  $core.String get label => $_getSZ(4);
  @$pb.TagNumber(5)
  set label($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLabel() => $_has(4);
  @$pb.TagNumber(5)
  void clearLabel() => clearField(5);

  /// UTXOs that must be included in the transaction.
  @$pb.TagNumber(6)
  $core.List<UnspentOutput> get requiredInputs => $_getList(5);
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
    $3.DenialInfo? denialInfo,
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
    ..aOM<$3.DenialInfo>(7, _omitFieldNames ? '' : 'denialInfo', subBuilder: $3.DenialInfo.create)
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
  $3.DenialInfo get denialInfo => $_getN(6);
  @$pb.TagNumber(7)
  set denialInfo($3.DenialInfo v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasDenialInfo() => $_has(6);
  @$pb.TagNumber(7)
  void clearDenialInfo() => clearField(7);
  @$pb.TagNumber(7)
  $3.DenialInfo ensureDenialInfo() => $_ensure(6);
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
    $core.int? slot,
  }) {
    final $result = create();
    if (slot != null) {
      $result.slot = slot;
    }
    return $result;
  }
  ListSidechainDepositsRequest._() : super();
  factory ListSidechainDepositsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.O3)
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
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => clearField(1);
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
    $fixnum.Int64? slot,
    $core.String? destination,
    $core.double? amount,
    $core.double? fee,
  }) {
    final $result = create();
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
    ..aInt64(1, _omitFieldNames ? '' : 'slot')
    ..aOS(2, _omitFieldNames ? '' : 'destination')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
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

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(1)
  $fixnum.Int64 get slot => $_getI64(0);
  @$pb.TagNumber(1)
  set slot($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => clearField(1);

  /// The sidechain deposit address to send to.
  @$pb.TagNumber(2)
  $core.String get destination => $_getSZ(1);
  @$pb.TagNumber(2)
  set destination($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDestination() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestination() => clearField(2);

  /// The amount in BTC to send. eg 0.1
  @$pb.TagNumber(3)
  $core.double get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  /// The fee in BTC
  @$pb.TagNumber(4)
  $core.double get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => clearField(4);
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
    $core.String? message,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SignMessageRequest._() : super();
  factory SignMessageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignMessageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignMessageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
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
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
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
    $core.String? message,
    $core.String? signature,
    $core.String? publicKey,
  }) {
    final $result = create();
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
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aOS(2, _omitFieldNames ? '' : 'signature')
    ..aOS(3, _omitFieldNames ? '' : 'publicKey')
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
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get signature => $_getSZ(1);
  @$pb.TagNumber(2)
  set signature($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get publicKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set publicKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicKey() => clearField(3);
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

class WalletServiceApi {
  $pb.RpcClient _client;
  WalletServiceApi(this._client);

  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
    _client.invoke<SendTransactionResponse>(ctx, 'WalletService', 'SendTransaction', request, SendTransactionResponse())
  ;
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'WalletService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'WalletService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'WalletService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListUnspentResponse>(ctx, 'WalletService', 'ListUnspent', request, ListUnspentResponse())
  ;
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses($pb.ClientContext? ctx, $1.Empty request) =>
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
  $async.Future<GetStatsResponse> getStats($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetStatsResponse>(ctx, 'WalletService', 'GetStats', request, GetStatsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
