//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
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

import '../../../google/protobuf/timestamp.pb.dart' as $5;
import '../../../google/protobuf/wrappers.pb.dart' as $0;
import '../../common/v1/common.pb.dart' as $1;
import 'common.pb.dart' as $3;

class WalletTransaction_Confirmation extends $pb.GeneratedMessage {
  factory WalletTransaction_Confirmation({
    $core.int? height,
    $1.ReverseHex? blockHash,
    $5.Timestamp? timestamp,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  WalletTransaction_Confirmation._() : super();
  factory WalletTransaction_Confirmation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletTransaction_Confirmation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletTransaction.Confirmation', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOM<$1.ReverseHex>(2, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$5.Timestamp>(3, _omitFieldNames ? '' : 'timestamp', subBuilder: $5.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletTransaction_Confirmation clone() => WalletTransaction_Confirmation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletTransaction_Confirmation copyWith(void Function(WalletTransaction_Confirmation) updates) => super.copyWith((message) => updates(message as WalletTransaction_Confirmation)) as WalletTransaction_Confirmation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletTransaction_Confirmation create() => WalletTransaction_Confirmation._();
  WalletTransaction_Confirmation createEmptyInstance() => create();
  static $pb.PbList<WalletTransaction_Confirmation> createRepeated() => $pb.PbList<WalletTransaction_Confirmation>();
  @$core.pragma('dart2js:noInline')
  static WalletTransaction_Confirmation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletTransaction_Confirmation>(create);
  static WalletTransaction_Confirmation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $1.ReverseHex get blockHash => $_getN(1);
  @$pb.TagNumber(2)
  set blockHash($1.ReverseHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockHash() => clearField(2);
  @$pb.TagNumber(2)
  $1.ReverseHex ensureBlockHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $5.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($5.Timestamp v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);
  @$pb.TagNumber(3)
  $5.Timestamp ensureTimestamp() => $_ensure(2);
}

class WalletTransaction extends $pb.GeneratedMessage {
  factory WalletTransaction({
    $1.ReverseHex? txid,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? receivedSats,
    $fixnum.Int64? sentSats,
    WalletTransaction_Confirmation? confirmationInfo,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (receivedSats != null) {
      $result.receivedSats = receivedSats;
    }
    if (sentSats != null) {
      $result.sentSats = sentSats;
    }
    if (confirmationInfo != null) {
      $result.confirmationInfo = confirmationInfo;
    }
    return $result;
  }
  WalletTransaction._() : super();
  factory WalletTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'receivedSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sentSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<WalletTransaction_Confirmation>(5, _omitFieldNames ? '' : 'confirmationInfo', subBuilder: WalletTransaction_Confirmation.create)
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
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get receivedSats => $_getI64(2);
  @$pb.TagNumber(3)
  set receivedSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReceivedSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sentSats => $_getI64(3);
  @$pb.TagNumber(4)
  set sentSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSentSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearSentSats() => clearField(4);

  @$pb.TagNumber(5)
  WalletTransaction_Confirmation get confirmationInfo => $_getN(4);
  @$pb.TagNumber(5)
  set confirmationInfo(WalletTransaction_Confirmation v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmationInfo() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmationInfo() => clearField(5);
  @$pb.TagNumber(5)
  WalletTransaction_Confirmation ensureConfirmationInfo() => $_ensure(4);
}

class BroadcastWithdrawalBundleRequest extends $pb.GeneratedMessage {
  factory BroadcastWithdrawalBundleRequest({
    $0.UInt32Value? sidechainId,
    $0.BytesValue? transaction,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  BroadcastWithdrawalBundleRequest._() : super();
  factory BroadcastWithdrawalBundleRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadcastWithdrawalBundleRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastWithdrawalBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.BytesValue>(2, _omitFieldNames ? '' : 'transaction', subBuilder: $0.BytesValue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadcastWithdrawalBundleRequest clone() => BroadcastWithdrawalBundleRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadcastWithdrawalBundleRequest copyWith(void Function(BroadcastWithdrawalBundleRequest) updates) => super.copyWith((message) => updates(message as BroadcastWithdrawalBundleRequest)) as BroadcastWithdrawalBundleRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastWithdrawalBundleRequest create() => BroadcastWithdrawalBundleRequest._();
  BroadcastWithdrawalBundleRequest createEmptyInstance() => create();
  static $pb.PbList<BroadcastWithdrawalBundleRequest> createRepeated() => $pb.PbList<BroadcastWithdrawalBundleRequest>();
  @$core.pragma('dart2js:noInline')
  static BroadcastWithdrawalBundleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastWithdrawalBundleRequest>(create);
  static BroadcastWithdrawalBundleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.BytesValue get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction($0.BytesValue v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => clearField(2);
  @$pb.TagNumber(2)
  $0.BytesValue ensureTransaction() => $_ensure(1);
}

class BroadcastWithdrawalBundleResponse extends $pb.GeneratedMessage {
  factory BroadcastWithdrawalBundleResponse() => create();
  BroadcastWithdrawalBundleResponse._() : super();
  factory BroadcastWithdrawalBundleResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadcastWithdrawalBundleResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastWithdrawalBundleResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadcastWithdrawalBundleResponse clone() => BroadcastWithdrawalBundleResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadcastWithdrawalBundleResponse copyWith(void Function(BroadcastWithdrawalBundleResponse) updates) => super.copyWith((message) => updates(message as BroadcastWithdrawalBundleResponse)) as BroadcastWithdrawalBundleResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastWithdrawalBundleResponse create() => BroadcastWithdrawalBundleResponse._();
  BroadcastWithdrawalBundleResponse createEmptyInstance() => create();
  static $pb.PbList<BroadcastWithdrawalBundleResponse> createRepeated() => $pb.PbList<BroadcastWithdrawalBundleResponse>();
  @$core.pragma('dart2js:noInline')
  static BroadcastWithdrawalBundleResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastWithdrawalBundleResponse>(create);
  static BroadcastWithdrawalBundleResponse? _defaultInstance;
}

class CreateBmmCriticalDataTransactionRequest extends $pb.GeneratedMessage {
  factory CreateBmmCriticalDataTransactionRequest({
    $0.UInt32Value? sidechainId,
    $0.UInt64Value? valueSats,
    $0.UInt32Value? height,
    $1.ConsensusHex? criticalHash,
    $1.ReverseHex? prevBytes,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (height != null) {
      $result.height = height;
    }
    if (criticalHash != null) {
      $result.criticalHash = criticalHash;
    }
    if (prevBytes != null) {
      $result.prevBytes = prevBytes;
    }
    return $result;
  }
  CreateBmmCriticalDataTransactionRequest._() : super();
  factory CreateBmmCriticalDataTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBmmCriticalDataTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBmmCriticalDataTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt64Value>(2, _omitFieldNames ? '' : 'valueSats', subBuilder: $0.UInt64Value.create)
    ..aOM<$0.UInt32Value>(3, _omitFieldNames ? '' : 'height', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ConsensusHex>(4, _omitFieldNames ? '' : 'criticalHash', subBuilder: $1.ConsensusHex.create)
    ..aOM<$1.ReverseHex>(5, _omitFieldNames ? '' : 'prevBytes', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBmmCriticalDataTransactionRequest clone() => CreateBmmCriticalDataTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBmmCriticalDataTransactionRequest copyWith(void Function(CreateBmmCriticalDataTransactionRequest) updates) => super.copyWith((message) => updates(message as CreateBmmCriticalDataTransactionRequest)) as CreateBmmCriticalDataTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBmmCriticalDataTransactionRequest create() => CreateBmmCriticalDataTransactionRequest._();
  CreateBmmCriticalDataTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateBmmCriticalDataTransactionRequest> createRepeated() => $pb.PbList<CreateBmmCriticalDataTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateBmmCriticalDataTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBmmCriticalDataTransactionRequest>(create);
  static CreateBmmCriticalDataTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.UInt64Value get valueSats => $_getN(1);
  @$pb.TagNumber(2)
  set valueSats($0.UInt64Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt64Value ensureValueSats() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.UInt32Value get height => $_getN(2);
  @$pb.TagNumber(3)
  set height($0.UInt32Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
  @$pb.TagNumber(3)
  $0.UInt32Value ensureHeight() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.ConsensusHex get criticalHash => $_getN(3);
  @$pb.TagNumber(4)
  set criticalHash($1.ConsensusHex v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCriticalHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearCriticalHash() => clearField(4);
  @$pb.TagNumber(4)
  $1.ConsensusHex ensureCriticalHash() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.ReverseHex get prevBytes => $_getN(4);
  @$pb.TagNumber(5)
  set prevBytes($1.ReverseHex v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrevBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevBytes() => clearField(5);
  @$pb.TagNumber(5)
  $1.ReverseHex ensurePrevBytes() => $_ensure(4);
}

class CreateBmmCriticalDataTransactionResponse extends $pb.GeneratedMessage {
  factory CreateBmmCriticalDataTransactionResponse({
    $1.ReverseHex? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateBmmCriticalDataTransactionResponse._() : super();
  factory CreateBmmCriticalDataTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBmmCriticalDataTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBmmCriticalDataTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBmmCriticalDataTransactionResponse clone() => CreateBmmCriticalDataTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBmmCriticalDataTransactionResponse copyWith(void Function(CreateBmmCriticalDataTransactionResponse) updates) => super.copyWith((message) => updates(message as CreateBmmCriticalDataTransactionResponse)) as CreateBmmCriticalDataTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBmmCriticalDataTransactionResponse create() => CreateBmmCriticalDataTransactionResponse._();
  CreateBmmCriticalDataTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateBmmCriticalDataTransactionResponse> createRepeated() => $pb.PbList<CreateBmmCriticalDataTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateBmmCriticalDataTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBmmCriticalDataTransactionResponse>(create);
  static CreateBmmCriticalDataTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);
}

class CreateDepositTransactionRequest extends $pb.GeneratedMessage {
  factory CreateDepositTransactionRequest({
    $0.UInt32Value? sidechainId,
    $0.StringValue? address,
    $0.UInt64Value? valueSats,
    $0.UInt64Value? feeSats,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  CreateDepositTransactionRequest._() : super();
  factory CreateDepositTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDepositTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.StringValue>(2, _omitFieldNames ? '' : 'address', subBuilder: $0.StringValue.create)
    ..aOM<$0.UInt64Value>(3, _omitFieldNames ? '' : 'valueSats', subBuilder: $0.UInt64Value.create)
    ..aOM<$0.UInt64Value>(4, _omitFieldNames ? '' : 'feeSats', subBuilder: $0.UInt64Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDepositTransactionRequest clone() => CreateDepositTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDepositTransactionRequest copyWith(void Function(CreateDepositTransactionRequest) updates) => super.copyWith((message) => updates(message as CreateDepositTransactionRequest)) as CreateDepositTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDepositTransactionRequest create() => CreateDepositTransactionRequest._();
  CreateDepositTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateDepositTransactionRequest> createRepeated() => $pb.PbList<CreateDepositTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateDepositTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDepositTransactionRequest>(create);
  static CreateDepositTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);

  /// Addresses are encoded in UTF8.
  /// *Sidechain deposit addresses* (not sidechain addresses) are typically
  /// formatted as `s<SLOT_NUMBER>_<ADDRESS>_<CHECKSUM>`,
  /// where `CHECKSUM` is a hex encoding of the first 6 bytes of the SHA256
  /// hash of `s<SLOT_NUMBER>_<ADDRESS>`.
  /// protolint:disable:next MAX_LINE_LENGTH
  /// https://github.com/LayerTwo-Labs/testchain-deprecated/blob/4b7bae3e1218e058f59a43caf6ccac2a4e9a91f6/src/sidechain.cpp#L219
  /// The address used here is a sidechain address, the middle component of a
  /// sidechain deposit address.
  @$pb.TagNumber(2)
  $0.StringValue get address => $_getN(1);
  @$pb.TagNumber(2)
  set address($0.StringValue v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);
  @$pb.TagNumber(2)
  $0.StringValue ensureAddress() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.UInt64Value get valueSats => $_getN(2);
  @$pb.TagNumber(3)
  set valueSats($0.UInt64Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueSats() => clearField(3);
  @$pb.TagNumber(3)
  $0.UInt64Value ensureValueSats() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.UInt64Value get feeSats => $_getN(3);
  @$pb.TagNumber(4)
  set feeSats($0.UInt64Value v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);
  @$pb.TagNumber(4)
  $0.UInt64Value ensureFeeSats() => $_ensure(3);
}

class CreateDepositTransactionResponse extends $pb.GeneratedMessage {
  factory CreateDepositTransactionResponse({
    $1.ReverseHex? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateDepositTransactionResponse._() : super();
  factory CreateDepositTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDepositTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDepositTransactionResponse clone() => CreateDepositTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDepositTransactionResponse copyWith(void Function(CreateDepositTransactionResponse) updates) => super.copyWith((message) => updates(message as CreateDepositTransactionResponse)) as CreateDepositTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDepositTransactionResponse create() => CreateDepositTransactionResponse._();
  CreateDepositTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateDepositTransactionResponse> createRepeated() => $pb.PbList<CreateDepositTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateDepositTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDepositTransactionResponse>(create);
  static CreateDepositTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);
}

class CreateNewAddressRequest extends $pb.GeneratedMessage {
  factory CreateNewAddressRequest() => create();
  CreateNewAddressRequest._() : super();
  factory CreateNewAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateNewAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateNewAddressRequest clone() => CreateNewAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateNewAddressRequest copyWith(void Function(CreateNewAddressRequest) updates) => super.copyWith((message) => updates(message as CreateNewAddressRequest)) as CreateNewAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateNewAddressRequest create() => CreateNewAddressRequest._();
  CreateNewAddressRequest createEmptyInstance() => create();
  static $pb.PbList<CreateNewAddressRequest> createRepeated() => $pb.PbList<CreateNewAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateNewAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateNewAddressRequest>(create);
  static CreateNewAddressRequest? _defaultInstance;
}

class CreateNewAddressResponse extends $pb.GeneratedMessage {
  factory CreateNewAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  CreateNewAddressResponse._() : super();
  factory CreateNewAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateNewAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateNewAddressResponse clone() => CreateNewAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateNewAddressResponse copyWith(void Function(CreateNewAddressResponse) updates) => super.copyWith((message) => updates(message as CreateNewAddressResponse)) as CreateNewAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateNewAddressResponse create() => CreateNewAddressResponse._();
  CreateNewAddressResponse createEmptyInstance() => create();
  static $pb.PbList<CreateNewAddressResponse> createRepeated() => $pb.PbList<CreateNewAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateNewAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateNewAddressResponse>(create);
  static CreateNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class CreateSidechainProposalRequest extends $pb.GeneratedMessage {
  factory CreateSidechainProposalRequest({
    $0.UInt32Value? sidechainId,
    $3.SidechainDeclaration? declaration,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (declaration != null) {
      $result.declaration = declaration;
    }
    return $result;
  }
  CreateSidechainProposalRequest._() : super();
  factory CreateSidechainProposalRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainProposalRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainProposalRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..aOM<$3.SidechainDeclaration>(2, _omitFieldNames ? '' : 'declaration', subBuilder: $3.SidechainDeclaration.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalRequest clone() => CreateSidechainProposalRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalRequest copyWith(void Function(CreateSidechainProposalRequest) updates) => super.copyWith((message) => updates(message as CreateSidechainProposalRequest)) as CreateSidechainProposalRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalRequest create() => CreateSidechainProposalRequest._();
  CreateSidechainProposalRequest createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainProposalRequest> createRepeated() => $pb.PbList<CreateSidechainProposalRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainProposalRequest>(create);
  static CreateSidechainProposalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.SidechainDeclaration get declaration => $_getN(1);
  @$pb.TagNumber(2)
  set declaration($3.SidechainDeclaration v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeclaration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeclaration() => clearField(2);
  @$pb.TagNumber(2)
  $3.SidechainDeclaration ensureDeclaration() => $_ensure(1);
}

class CreateSidechainProposalResponse_Confirmed extends $pb.GeneratedMessage {
  factory CreateSidechainProposalResponse_Confirmed({
    $1.ReverseHex? blockHash,
    $0.UInt32Value? confirmations,
    $0.UInt32Value? height,
    $3.OutPoint? outpoint,
    $1.ReverseHex? prevBlockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (height != null) {
      $result.height = height;
    }
    if (outpoint != null) {
      $result.outpoint = outpoint;
    }
    if (prevBlockHash != null) {
      $result.prevBlockHash = prevBlockHash;
    }
    return $result;
  }
  CreateSidechainProposalResponse_Confirmed._() : super();
  factory CreateSidechainProposalResponse_Confirmed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainProposalResponse_Confirmed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainProposalResponse.Confirmed', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(2, _omitFieldNames ? '' : 'confirmations', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt32Value>(3, _omitFieldNames ? '' : 'height', subBuilder: $0.UInt32Value.create)
    ..aOM<$3.OutPoint>(4, _omitFieldNames ? '' : 'outpoint', subBuilder: $3.OutPoint.create)
    ..aOM<$1.ReverseHex>(5, _omitFieldNames ? '' : 'prevBlockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse_Confirmed clone() => CreateSidechainProposalResponse_Confirmed()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse_Confirmed copyWith(void Function(CreateSidechainProposalResponse_Confirmed) updates) => super.copyWith((message) => updates(message as CreateSidechainProposalResponse_Confirmed)) as CreateSidechainProposalResponse_Confirmed;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse_Confirmed create() => CreateSidechainProposalResponse_Confirmed._();
  CreateSidechainProposalResponse_Confirmed createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainProposalResponse_Confirmed> createRepeated() => $pb.PbList<CreateSidechainProposalResponse_Confirmed>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse_Confirmed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainProposalResponse_Confirmed>(create);
  static CreateSidechainProposalResponse_Confirmed? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.UInt32Value get confirmations => $_getN(1);
  @$pb.TagNumber(2)
  set confirmations($0.UInt32Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasConfirmations() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmations() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt32Value ensureConfirmations() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.UInt32Value get height => $_getN(2);
  @$pb.TagNumber(3)
  set height($0.UInt32Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
  @$pb.TagNumber(3)
  $0.UInt32Value ensureHeight() => $_ensure(2);

  @$pb.TagNumber(4)
  $3.OutPoint get outpoint => $_getN(3);
  @$pb.TagNumber(4)
  set outpoint($3.OutPoint v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasOutpoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearOutpoint() => clearField(4);
  @$pb.TagNumber(4)
  $3.OutPoint ensureOutpoint() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.ReverseHex get prevBlockHash => $_getN(4);
  @$pb.TagNumber(5)
  set prevBlockHash($1.ReverseHex v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrevBlockHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevBlockHash() => clearField(5);
  @$pb.TagNumber(5)
  $1.ReverseHex ensurePrevBlockHash() => $_ensure(4);
}

class CreateSidechainProposalResponse_NotConfirmed extends $pb.GeneratedMessage {
  factory CreateSidechainProposalResponse_NotConfirmed({
    $1.ReverseHex? blockHash,
    $0.UInt32Value? height,
    $1.ReverseHex? prevBlockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (height != null) {
      $result.height = height;
    }
    if (prevBlockHash != null) {
      $result.prevBlockHash = prevBlockHash;
    }
    return $result;
  }
  CreateSidechainProposalResponse_NotConfirmed._() : super();
  factory CreateSidechainProposalResponse_NotConfirmed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainProposalResponse_NotConfirmed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainProposalResponse.NotConfirmed', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(2, _omitFieldNames ? '' : 'height', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ReverseHex>(3, _omitFieldNames ? '' : 'prevBlockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse_NotConfirmed clone() => CreateSidechainProposalResponse_NotConfirmed()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse_NotConfirmed copyWith(void Function(CreateSidechainProposalResponse_NotConfirmed) updates) => super.copyWith((message) => updates(message as CreateSidechainProposalResponse_NotConfirmed)) as CreateSidechainProposalResponse_NotConfirmed;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse_NotConfirmed create() => CreateSidechainProposalResponse_NotConfirmed._();
  CreateSidechainProposalResponse_NotConfirmed createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainProposalResponse_NotConfirmed> createRepeated() => $pb.PbList<CreateSidechainProposalResponse_NotConfirmed>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse_NotConfirmed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainProposalResponse_NotConfirmed>(create);
  static CreateSidechainProposalResponse_NotConfirmed? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.UInt32Value get height => $_getN(1);
  @$pb.TagNumber(2)
  set height($0.UInt32Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt32Value ensureHeight() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ReverseHex get prevBlockHash => $_getN(2);
  @$pb.TagNumber(3)
  set prevBlockHash($1.ReverseHex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevBlockHash() => clearField(3);
  @$pb.TagNumber(3)
  $1.ReverseHex ensurePrevBlockHash() => $_ensure(2);
}

enum CreateSidechainProposalResponse_Event {
  confirmed, 
  notConfirmed, 
  notSet
}

class CreateSidechainProposalResponse extends $pb.GeneratedMessage {
  factory CreateSidechainProposalResponse({
    CreateSidechainProposalResponse_Confirmed? confirmed,
    CreateSidechainProposalResponse_NotConfirmed? notConfirmed,
  }) {
    final $result = create();
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (notConfirmed != null) {
      $result.notConfirmed = notConfirmed;
    }
    return $result;
  }
  CreateSidechainProposalResponse._() : super();
  factory CreateSidechainProposalResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSidechainProposalResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, CreateSidechainProposalResponse_Event> _CreateSidechainProposalResponse_EventByTag = {
    1 : CreateSidechainProposalResponse_Event.confirmed,
    2 : CreateSidechainProposalResponse_Event.notConfirmed,
    0 : CreateSidechainProposalResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSidechainProposalResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<CreateSidechainProposalResponse_Confirmed>(1, _omitFieldNames ? '' : 'confirmed', subBuilder: CreateSidechainProposalResponse_Confirmed.create)
    ..aOM<CreateSidechainProposalResponse_NotConfirmed>(2, _omitFieldNames ? '' : 'notConfirmed', subBuilder: CreateSidechainProposalResponse_NotConfirmed.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse clone() => CreateSidechainProposalResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSidechainProposalResponse copyWith(void Function(CreateSidechainProposalResponse) updates) => super.copyWith((message) => updates(message as CreateSidechainProposalResponse)) as CreateSidechainProposalResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse create() => CreateSidechainProposalResponse._();
  CreateSidechainProposalResponse createEmptyInstance() => create();
  static $pb.PbList<CreateSidechainProposalResponse> createRepeated() => $pb.PbList<CreateSidechainProposalResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateSidechainProposalResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSidechainProposalResponse>(create);
  static CreateSidechainProposalResponse? _defaultInstance;

  CreateSidechainProposalResponse_Event whichEvent() => _CreateSidechainProposalResponse_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  CreateSidechainProposalResponse_Confirmed get confirmed => $_getN(0);
  @$pb.TagNumber(1)
  set confirmed(CreateSidechainProposalResponse_Confirmed v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmed() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmed() => clearField(1);
  @$pb.TagNumber(1)
  CreateSidechainProposalResponse_Confirmed ensureConfirmed() => $_ensure(0);

  @$pb.TagNumber(2)
  CreateSidechainProposalResponse_NotConfirmed get notConfirmed => $_getN(1);
  @$pb.TagNumber(2)
  set notConfirmed(CreateSidechainProposalResponse_NotConfirmed v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNotConfirmed() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotConfirmed() => clearField(2);
  @$pb.TagNumber(2)
  CreateSidechainProposalResponse_NotConfirmed ensureNotConfirmed() => $_ensure(1);
}

class CreateWalletRequest extends $pb.GeneratedMessage {
  factory CreateWalletRequest({
    $core.Iterable<$core.String>? mnemonicWords,
    $core.String? mnemonicPath,
    $core.String? password,
  }) {
    final $result = create();
    if (mnemonicWords != null) {
      $result.mnemonicWords.addAll(mnemonicWords);
    }
    if (mnemonicPath != null) {
      $result.mnemonicPath = mnemonicPath;
    }
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  CreateWalletRequest._() : super();
  factory CreateWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'mnemonicWords')
    ..aOS(2, _omitFieldNames ? '' : 'mnemonicPath')
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletRequest clone() => CreateWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletRequest copyWith(void Function(CreateWalletRequest) updates) => super.copyWith((message) => updates(message as CreateWalletRequest)) as CreateWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest create() => CreateWalletRequest._();
  CreateWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateWalletRequest> createRepeated() => $pb.PbList<CreateWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletRequest>(create);
  static CreateWalletRequest? _defaultInstance;

  /// BIP39 mnemonic. 12 or 24 words.
  @$pb.TagNumber(1)
  $core.List<$core.String> get mnemonicWords => $_getList(0);

  /// Path to a file containing the mnemonic.
  @$pb.TagNumber(2)
  $core.String get mnemonicPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonicPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMnemonicPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonicPath() => clearField(2);

  /// Password for the wallet. Used to encrypt the mnemonic in storage.
  /// NOT a BIP39 passphrase.
  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => clearField(3);
}

class CreateWalletResponse extends $pb.GeneratedMessage {
  factory CreateWalletResponse() => create();
  CreateWalletResponse._() : super();
  factory CreateWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletResponse clone() => CreateWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletResponse copyWith(void Function(CreateWalletResponse) updates) => super.copyWith((message) => updates(message as CreateWalletResponse)) as CreateWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse create() => CreateWalletResponse._();
  CreateWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateWalletResponse> createRepeated() => $pb.PbList<CreateWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletResponse>(create);
  static CreateWalletResponse? _defaultInstance;
}

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest() => create();
  GetBalanceRequest._() : super();
  factory GetBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
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
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $fixnum.Int64? confirmedSats,
    $fixnum.Int64? pendingSats,
  }) {
    final $result = create();
    if (confirmedSats != null) {
      $result.confirmedSats = confirmedSats;
    }
    if (pendingSats != null) {
      $result.pendingSats = pendingSats;
    }
    return $result;
  }
  GetBalanceResponse._() : super();
  factory GetBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'confirmedSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'pendingSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
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
  $fixnum.Int64 get confirmedSats => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSats => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPendingSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSats() => clearField(2);
}

class ListSidechainDepositTransactionsRequest extends $pb.GeneratedMessage {
  factory ListSidechainDepositTransactionsRequest() => create();
  ListSidechainDepositTransactionsRequest._() : super();
  factory ListSidechainDepositTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsRequest clone() => ListSidechainDepositTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsRequest copyWith(void Function(ListSidechainDepositTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListSidechainDepositTransactionsRequest)) as ListSidechainDepositTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsRequest create() => ListSidechainDepositTransactionsRequest._();
  ListSidechainDepositTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositTransactionsRequest> createRepeated() => $pb.PbList<ListSidechainDepositTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositTransactionsRequest>(create);
  static ListSidechainDepositTransactionsRequest? _defaultInstance;
}

class ListSidechainDepositTransactionsResponse_SidechainDepositTransaction extends $pb.GeneratedMessage {
  factory ListSidechainDepositTransactionsResponse_SidechainDepositTransaction({
    $0.UInt32Value? sidechainNumber,
    WalletTransaction? tx,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (tx != null) {
      $result.tx = tx;
    }
    return $result;
  }
  ListSidechainDepositTransactionsResponse_SidechainDepositTransaction._() : super();
  factory ListSidechainDepositTransactionsResponse_SidechainDepositTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositTransactionsResponse_SidechainDepositTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositTransactionsResponse.SidechainDepositTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<WalletTransaction>(2, _omitFieldNames ? '' : 'tx', subBuilder: WalletTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsResponse_SidechainDepositTransaction clone() => ListSidechainDepositTransactionsResponse_SidechainDepositTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsResponse_SidechainDepositTransaction copyWith(void Function(ListSidechainDepositTransactionsResponse_SidechainDepositTransaction) updates) => super.copyWith((message) => updates(message as ListSidechainDepositTransactionsResponse_SidechainDepositTransaction)) as ListSidechainDepositTransactionsResponse_SidechainDepositTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsResponse_SidechainDepositTransaction create() => ListSidechainDepositTransactionsResponse_SidechainDepositTransaction._();
  ListSidechainDepositTransactionsResponse_SidechainDepositTransaction createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction> createRepeated() => $pb.PbList<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsResponse_SidechainDepositTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction>(create);
  static ListSidechainDepositTransactionsResponse_SidechainDepositTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  WalletTransaction get tx => $_getN(1);
  @$pb.TagNumber(2)
  set tx(WalletTransaction v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTx() => $_has(1);
  @$pb.TagNumber(2)
  void clearTx() => clearField(2);
  @$pb.TagNumber(2)
  WalletTransaction ensureTx() => $_ensure(1);
}

class ListSidechainDepositTransactionsResponse extends $pb.GeneratedMessage {
  factory ListSidechainDepositTransactionsResponse({
    $core.Iterable<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListSidechainDepositTransactionsResponse._() : super();
  factory ListSidechainDepositTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainDepositTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pc<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: ListSidechainDepositTransactionsResponse_SidechainDepositTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsResponse clone() => ListSidechainDepositTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainDepositTransactionsResponse copyWith(void Function(ListSidechainDepositTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListSidechainDepositTransactionsResponse)) as ListSidechainDepositTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsResponse create() => ListSidechainDepositTransactionsResponse._();
  ListSidechainDepositTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSidechainDepositTransactionsResponse> createRepeated() => $pb.PbList<ListSidechainDepositTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositTransactionsResponse>(create);
  static ListSidechainDepositTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ListSidechainDepositTransactionsResponse_SidechainDepositTransaction> get transactions => $_getList(0);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest() => create();
  ListTransactionsRequest._() : super();
  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
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

enum SendTransactionRequest_FeeRate_Fee {
  satPerVbyte, 
  sats, 
  notSet
}

class SendTransactionRequest_FeeRate extends $pb.GeneratedMessage {
  factory SendTransactionRequest_FeeRate({
    $fixnum.Int64? satPerVbyte,
    $fixnum.Int64? sats,
  }) {
    final $result = create();
    if (satPerVbyte != null) {
      $result.satPerVbyte = satPerVbyte;
    }
    if (sats != null) {
      $result.sats = sats;
    }
    return $result;
  }
  SendTransactionRequest_FeeRate._() : super();
  factory SendTransactionRequest_FeeRate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionRequest_FeeRate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SendTransactionRequest_FeeRate_Fee> _SendTransactionRequest_FeeRate_FeeByTag = {
    1 : SendTransactionRequest_FeeRate_Fee.satPerVbyte,
    2 : SendTransactionRequest_FeeRate_Fee.sats,
    0 : SendTransactionRequest_FeeRate_Fee.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest.FeeRate', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'satPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'sats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendTransactionRequest_FeeRate clone() => SendTransactionRequest_FeeRate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendTransactionRequest_FeeRate copyWith(void Function(SendTransactionRequest_FeeRate) updates) => super.copyWith((message) => updates(message as SendTransactionRequest_FeeRate)) as SendTransactionRequest_FeeRate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest_FeeRate create() => SendTransactionRequest_FeeRate._();
  SendTransactionRequest_FeeRate createEmptyInstance() => create();
  static $pb.PbList<SendTransactionRequest_FeeRate> createRepeated() => $pb.PbList<SendTransactionRequest_FeeRate>();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest_FeeRate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest_FeeRate>(create);
  static SendTransactionRequest_FeeRate? _defaultInstance;

  SendTransactionRequest_FeeRate_Fee whichFee() => _SendTransactionRequest_FeeRate_FeeByTag[$_whichOneof(0)]!;
  void clearFee() => clearField($_whichOneof(0));

  /// Fee rate, measured in sat/vbyte.
  @$pb.TagNumber(1)
  $fixnum.Int64 get satPerVbyte => $_getI64(0);
  @$pb.TagNumber(1)
  set satPerVbyte($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSatPerVbyte() => $_has(0);
  @$pb.TagNumber(1)
  void clearSatPerVbyte() => clearField(1);

  /// Fee amount, measured in sats.
  @$pb.TagNumber(2)
  $fixnum.Int64 get sats => $_getI64(1);
  @$pb.TagNumber(2)
  set sats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearSats() => clearField(2);
}

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.Map<$core.String, $fixnum.Int64>? destinations,
    SendTransactionRequest_FeeRate? feeRate,
    $1.Hex? opReturnMessage,
  }) {
    final $result = create();
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (feeRate != null) {
      $result.feeRate = feeRate;
    }
    if (opReturnMessage != null) {
      $result.opReturnMessage = opReturnMessage;
    }
    return $result;
  }
  SendTransactionRequest._() : super();
  factory SendTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..m<$core.String, $fixnum.Int64>(1, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendTransactionRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OU6, packageName: const $pb.PackageName('cusf.mainchain.v1'))
    ..aOM<SendTransactionRequest_FeeRate>(2, _omitFieldNames ? '' : 'feeRate', subBuilder: SendTransactionRequest_FeeRate.create)
    ..aOM<$1.Hex>(3, _omitFieldNames ? '' : 'opReturnMessage', subBuilder: $1.Hex.create)
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

  /// If not set, a reasonable rate is used by asking Core for an estimate.
  @$pb.TagNumber(2)
  SendTransactionRequest_FeeRate get feeRate => $_getN(1);
  @$pb.TagNumber(2)
  set feeRate(SendTransactionRequest_FeeRate v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeRate() => clearField(2);
  @$pb.TagNumber(2)
  SendTransactionRequest_FeeRate ensureFeeRate() => $_ensure(1);

  /// if set, the transaction will add a separate OP_RETURN output with this
  /// message.
  @$pb.TagNumber(3)
  $1.Hex get opReturnMessage => $_getN(2);
  @$pb.TagNumber(3)
  set opReturnMessage($1.Hex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasOpReturnMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearOpReturnMessage() => clearField(3);
  @$pb.TagNumber(3)
  $1.Hex ensureOpReturnMessage() => $_ensure(2);
}

class SendTransactionResponse extends $pb.GeneratedMessage {
  factory SendTransactionResponse({
    $1.ReverseHex? txid,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
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
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);
}

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
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

class UnlockWalletResponse extends $pb.GeneratedMessage {
  factory UnlockWalletResponse() => create();
  UnlockWalletResponse._() : super();
  factory UnlockWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnlockWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnlockWalletResponse clone() => UnlockWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnlockWalletResponse copyWith(void Function(UnlockWalletResponse) updates) => super.copyWith((message) => updates(message as UnlockWalletResponse)) as UnlockWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockWalletResponse create() => UnlockWalletResponse._();
  UnlockWalletResponse createEmptyInstance() => create();
  static $pb.PbList<UnlockWalletResponse> createRepeated() => $pb.PbList<UnlockWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletResponse>(create);
  static UnlockWalletResponse? _defaultInstance;
}

class GenerateBlocksRequest extends $pb.GeneratedMessage {
  factory GenerateBlocksRequest({
    $0.UInt32Value? blocks,
    $core.bool? ackAllProposals,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (ackAllProposals != null) {
      $result.ackAllProposals = ackAllProposals;
    }
    return $result;
  }
  GenerateBlocksRequest._() : super();
  factory GenerateBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'blocks', subBuilder: $0.UInt32Value.create)
    ..aOB(2, _omitFieldNames ? '' : 'ackAllProposals')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateBlocksRequest clone() => GenerateBlocksRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateBlocksRequest copyWith(void Function(GenerateBlocksRequest) updates) => super.copyWith((message) => updates(message as GenerateBlocksRequest)) as GenerateBlocksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateBlocksRequest create() => GenerateBlocksRequest._();
  GenerateBlocksRequest createEmptyInstance() => create();
  static $pb.PbList<GenerateBlocksRequest> createRepeated() => $pb.PbList<GenerateBlocksRequest>();
  @$core.pragma('dart2js:noInline')
  static GenerateBlocksRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateBlocksRequest>(create);
  static GenerateBlocksRequest? _defaultInstance;

  /// Number of blocks to generate.
  @$pb.TagNumber(1)
  $0.UInt32Value get blocks => $_getN(0);
  @$pb.TagNumber(1)
  set blocks($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureBlocks() => $_ensure(0);

  /// ACK all sidechain proposals, irregardless of if they are already
  /// in the wallet DB.
  @$pb.TagNumber(2)
  $core.bool get ackAllProposals => $_getBF(1);
  @$pb.TagNumber(2)
  set ackAllProposals($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAckAllProposals() => $_has(1);
  @$pb.TagNumber(2)
  void clearAckAllProposals() => clearField(2);
}

class GenerateBlocksResponse extends $pb.GeneratedMessage {
  factory GenerateBlocksResponse({
    $1.ReverseHex? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  GenerateBlocksResponse._() : super();
  factory GenerateBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateBlocksResponse clone() => GenerateBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateBlocksResponse copyWith(void Function(GenerateBlocksResponse) updates) => super.copyWith((message) => updates(message as GenerateBlocksResponse)) as GenerateBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateBlocksResponse create() => GenerateBlocksResponse._();
  GenerateBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<GenerateBlocksResponse> createRepeated() => $pb.PbList<GenerateBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static GenerateBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateBlocksResponse>(create);
  static GenerateBlocksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);
}

class WalletServiceApi {
  $pb.RpcClient _client;
  WalletServiceApi(this._client);

  $async.Future<BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle($pb.ClientContext? ctx, BroadcastWithdrawalBundleRequest request) =>
    _client.invoke<BroadcastWithdrawalBundleResponse>(ctx, 'WalletService', 'BroadcastWithdrawalBundle', request, BroadcastWithdrawalBundleResponse())
  ;
  $async.Future<CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction($pb.ClientContext? ctx, CreateBmmCriticalDataTransactionRequest request) =>
    _client.invoke<CreateBmmCriticalDataTransactionResponse>(ctx, 'WalletService', 'CreateBmmCriticalDataTransaction', request, CreateBmmCriticalDataTransactionResponse())
  ;
  $async.Future<CreateDepositTransactionResponse> createDepositTransaction($pb.ClientContext? ctx, CreateDepositTransactionRequest request) =>
    _client.invoke<CreateDepositTransactionResponse>(ctx, 'WalletService', 'CreateDepositTransaction', request, CreateDepositTransactionResponse())
  ;
  $async.Future<CreateNewAddressResponse> createNewAddress($pb.ClientContext? ctx, CreateNewAddressRequest request) =>
    _client.invoke<CreateNewAddressResponse>(ctx, 'WalletService', 'CreateNewAddress', request, CreateNewAddressResponse())
  ;
  $async.Future<CreateSidechainProposalResponse> createSidechainProposal($pb.ClientContext? ctx, CreateSidechainProposalRequest request) =>
    _client.invoke<CreateSidechainProposalResponse>(ctx, 'WalletService', 'CreateSidechainProposal', request, CreateSidechainProposalResponse())
  ;
  $async.Future<CreateWalletResponse> createWallet($pb.ClientContext? ctx, CreateWalletRequest request) =>
    _client.invoke<CreateWalletResponse>(ctx, 'WalletService', 'CreateWallet', request, CreateWalletResponse())
  ;
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'WalletService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<ListSidechainDepositTransactionsResponse> listSidechainDepositTransactions($pb.ClientContext? ctx, ListSidechainDepositTransactionsRequest request) =>
    _client.invoke<ListSidechainDepositTransactionsResponse>(ctx, 'WalletService', 'ListSidechainDepositTransactions', request, ListSidechainDepositTransactionsResponse())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'WalletService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
    _client.invoke<SendTransactionResponse>(ctx, 'WalletService', 'SendTransaction', request, SendTransactionResponse())
  ;
  $async.Future<UnlockWalletResponse> unlockWallet($pb.ClientContext? ctx, UnlockWalletRequest request) =>
    _client.invoke<UnlockWalletResponse>(ctx, 'WalletService', 'UnlockWallet', request, UnlockWalletResponse())
  ;
  $async.Future<GenerateBlocksResponse> generateBlocks($pb.ClientContext? ctx, GenerateBlocksRequest request) =>
    _client.invoke<GenerateBlocksResponse>(ctx, 'WalletService', 'GenerateBlocks', request, GenerateBlocksResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
