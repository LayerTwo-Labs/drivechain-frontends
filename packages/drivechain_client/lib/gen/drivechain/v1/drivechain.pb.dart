//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $2;

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
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
    $core.double? satoshiPerVbyte,
  }) {
    final $result = create();
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (satoshiPerVbyte != null) {
      $result.satoshiPerVbyte = satoshiPerVbyte;
    }
    return $result;
  }
  SendTransactionRequest._() : super();
  factory SendTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..m<$core.String, $fixnum.Int64>(1, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendTransactionRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OU6, packageName: const $pb.PackageName('drivechain.v1'))
    ..a<$core.double>(2, _omitFieldNames ? '' : 'satoshiPerVbyte', $pb.PbFieldType.OD)
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

  /// Address -> satoshi amount
  @$pb.TagNumber(1)
  $core.Map<$core.String, $fixnum.Int64> get destinations => $_getMap(0);

  /// Fee rate, measured in satoshis/virtual byte. If set to zero,
  /// a reasonable rate is used by asking Core for an estimate.
  @$pb.TagNumber(2)
  $core.double get satoshiPerVbyte => $_getN(1);
  @$pb.TagNumber(2)
  set satoshiPerVbyte($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSatoshiPerVbyte() => $_has(1);
  @$pb.TagNumber(2)
  void clearSatoshiPerVbyte() => clearField(2);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
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
    $core.Iterable<Transaction>? transactions,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<Transaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: Transaction.create)
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
  $core.List<Transaction> get transactions => $_getList(0);
}

class Confirmation extends $pb.GeneratedMessage {
  factory Confirmation({
    $core.int? height,
    $2.Timestamp? timestamp,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Confirmation', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'timestamp', subBuilder: $2.Timestamp.create)
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
  $2.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($2.Timestamp v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureTimestamp() => $_ensure(1);
}

class Transaction extends $pb.GeneratedMessage {
  factory Transaction({
    $core.String? txid,
    $fixnum.Int64? feeSatoshi,
    $fixnum.Int64? receivedSatoshi,
    $fixnum.Int64? sentSatoshi,
    Confirmation? confirmationTime,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSatoshi != null) {
      $result.feeSatoshi = feeSatoshi;
    }
    if (receivedSatoshi != null) {
      $result.receivedSatoshi = receivedSatoshi;
    }
    if (sentSatoshi != null) {
      $result.sentSatoshi = sentSatoshi;
    }
    if (confirmationTime != null) {
      $result.confirmationTime = confirmationTime;
    }
    return $result;
  }
  Transaction._() : super();
  factory Transaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Transaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Transaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'receivedSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sentSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Confirmation>(5, _omitFieldNames ? '' : 'confirmationTime', subBuilder: Confirmation.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Transaction clone() => Transaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Transaction copyWith(void Function(Transaction) updates) => super.copyWith((message) => updates(message as Transaction)) as Transaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Transaction create() => Transaction._();
  Transaction createEmptyInstance() => create();
  static $pb.PbList<Transaction> createRepeated() => $pb.PbList<Transaction>();
  @$core.pragma('dart2js:noInline')
  static Transaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Transaction>(create);
  static Transaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSatoshi => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSatoshi($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSatoshi() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSatoshi() => clearField(2);

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
  Confirmation get confirmationTime => $_getN(4);
  @$pb.TagNumber(5)
  set confirmationTime(Confirmation v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmationTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmationTime() => clearField(5);
  @$pb.TagNumber(5)
  Confirmation ensureConfirmationTime() => $_ensure(4);
}

class ListRecentBlocksResponse_RecentBlock extends $pb.GeneratedMessage {
  factory ListRecentBlocksResponse_RecentBlock({
    $2.Timestamp? blockTime,
    $core.int? blockHeight,
    $core.String? hash,
  }) {
    final $result = create();
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  ListRecentBlocksResponse_RecentBlock._() : super();
  factory ListRecentBlocksResponse_RecentBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentBlocksResponse_RecentBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentBlocksResponse.RecentBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOM<$2.Timestamp>(1, _omitFieldNames ? '' : 'blockTime', subBuilder: $2.Timestamp.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentBlocksResponse_RecentBlock clone() => ListRecentBlocksResponse_RecentBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentBlocksResponse_RecentBlock copyWith(void Function(ListRecentBlocksResponse_RecentBlock) updates) => super.copyWith((message) => updates(message as ListRecentBlocksResponse_RecentBlock)) as ListRecentBlocksResponse_RecentBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentBlocksResponse_RecentBlock create() => ListRecentBlocksResponse_RecentBlock._();
  ListRecentBlocksResponse_RecentBlock createEmptyInstance() => create();
  static $pb.PbList<ListRecentBlocksResponse_RecentBlock> createRepeated() => $pb.PbList<ListRecentBlocksResponse_RecentBlock>();
  @$core.pragma('dart2js:noInline')
  static ListRecentBlocksResponse_RecentBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentBlocksResponse_RecentBlock>(create);
  static ListRecentBlocksResponse_RecentBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Timestamp get blockTime => $_getN(0);
  @$pb.TagNumber(1)
  set blockTime($2.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockTime() => clearField(1);
  @$pb.TagNumber(1)
  $2.Timestamp ensureBlockTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get blockHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockHeight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set hash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => clearField(3);
}

class ListRecentBlocksResponse extends $pb.GeneratedMessage {
  factory ListRecentBlocksResponse({
    $core.Iterable<ListRecentBlocksResponse_RecentBlock>? recentBlocks,
  }) {
    final $result = create();
    if (recentBlocks != null) {
      $result.recentBlocks.addAll(recentBlocks);
    }
    return $result;
  }
  ListRecentBlocksResponse._() : super();
  factory ListRecentBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<ListRecentBlocksResponse_RecentBlock>(4, _omitFieldNames ? '' : 'recentBlocks', $pb.PbFieldType.PM, subBuilder: ListRecentBlocksResponse_RecentBlock.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentBlocksResponse clone() => ListRecentBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentBlocksResponse copyWith(void Function(ListRecentBlocksResponse) updates) => super.copyWith((message) => updates(message as ListRecentBlocksResponse)) as ListRecentBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentBlocksResponse create() => ListRecentBlocksResponse._();
  ListRecentBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<ListRecentBlocksResponse> createRepeated() => $pb.PbList<ListRecentBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListRecentBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentBlocksResponse>(create);
  static ListRecentBlocksResponse? _defaultInstance;

  @$pb.TagNumber(4)
  $core.List<ListRecentBlocksResponse_RecentBlock> get recentBlocks => $_getList(0);
}

class ListUnconfirmedTransactionsResponse extends $pb.GeneratedMessage {
  factory ListUnconfirmedTransactionsResponse({
    $core.Iterable<UnconfirmedTransaction>? unconfirmedTransactions,
  }) {
    final $result = create();
    if (unconfirmedTransactions != null) {
      $result.unconfirmedTransactions.addAll(unconfirmedTransactions);
    }
    return $result;
  }
  ListUnconfirmedTransactionsResponse._() : super();
  factory ListUnconfirmedTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnconfirmedTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnconfirmedTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<UnconfirmedTransaction>(1, _omitFieldNames ? '' : 'unconfirmedTransactions', $pb.PbFieldType.PM, subBuilder: UnconfirmedTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnconfirmedTransactionsResponse clone() => ListUnconfirmedTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnconfirmedTransactionsResponse copyWith(void Function(ListUnconfirmedTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListUnconfirmedTransactionsResponse)) as ListUnconfirmedTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnconfirmedTransactionsResponse create() => ListUnconfirmedTransactionsResponse._();
  ListUnconfirmedTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListUnconfirmedTransactionsResponse> createRepeated() => $pb.PbList<ListUnconfirmedTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListUnconfirmedTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnconfirmedTransactionsResponse>(create);
  static ListUnconfirmedTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UnconfirmedTransaction> get unconfirmedTransactions => $_getList(0);
}

class UnconfirmedTransaction extends $pb.GeneratedMessage {
  factory UnconfirmedTransaction({
    $core.int? virtualSize,
    $core.int? weight,
    $2.Timestamp? time,
    $core.String? txid,
    $fixnum.Int64? feeSatoshi,
  }) {
    final $result = create();
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (time != null) {
      $result.time = time;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSatoshi != null) {
      $result.feeSatoshi = feeSatoshi;
    }
    return $result;
  }
  UnconfirmedTransaction._() : super();
  factory UnconfirmedTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnconfirmedTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnconfirmedTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.OU3)
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'time', subBuilder: $2.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSatoshi', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnconfirmedTransaction clone() => UnconfirmedTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnconfirmedTransaction copyWith(void Function(UnconfirmedTransaction) updates) => super.copyWith((message) => updates(message as UnconfirmedTransaction)) as UnconfirmedTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnconfirmedTransaction create() => UnconfirmedTransaction._();
  UnconfirmedTransaction createEmptyInstance() => create();
  static $pb.PbList<UnconfirmedTransaction> createRepeated() => $pb.PbList<UnconfirmedTransaction>();
  @$core.pragma('dart2js:noInline')
  static UnconfirmedTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnconfirmedTransaction>(create);
  static UnconfirmedTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get weight => $_getIZ(1);
  @$pb.TagNumber(2)
  set weight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get time => $_getN(2);
  @$pb.TagNumber(3)
  set time($2.Timestamp v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSatoshi => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSatoshi($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeeSatoshi() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSatoshi() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
