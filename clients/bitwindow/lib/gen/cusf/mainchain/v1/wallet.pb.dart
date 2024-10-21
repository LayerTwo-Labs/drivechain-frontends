//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/wrappers.pb.dart' as $3;
import 'common.pb.dart' as $4;

class BroadcastWithdrawalBundleRequest extends $pb.GeneratedMessage {
  factory BroadcastWithdrawalBundleRequest({
    $3.UInt32Value? sidechainId,
    $3.BytesValue? transaction,
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
    ..aOM<$3.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $3.UInt32Value.create)
    ..aOM<$3.BytesValue>(2, _omitFieldNames ? '' : 'transaction', subBuilder: $3.BytesValue.create)
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
  $3.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($3.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $3.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.BytesValue get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction($3.BytesValue v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => clearField(2);
  @$pb.TagNumber(2)
  $3.BytesValue ensureTransaction() => $_ensure(1);
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
    $3.UInt32Value? sidechainId,
    $3.UInt64Value? valueSats,
    $3.UInt32Value? height,
    $4.ConsensusHex? criticalHash,
    $4.ReverseHex? prevBytes,
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
    ..aOM<$3.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $3.UInt32Value.create)
    ..aOM<$3.UInt64Value>(2, _omitFieldNames ? '' : 'valueSats', subBuilder: $3.UInt64Value.create)
    ..aOM<$3.UInt32Value>(3, _omitFieldNames ? '' : 'height', subBuilder: $3.UInt32Value.create)
    ..aOM<$4.ConsensusHex>(4, _omitFieldNames ? '' : 'criticalHash', subBuilder: $4.ConsensusHex.create)
    ..aOM<$4.ReverseHex>(5, _omitFieldNames ? '' : 'prevBytes', subBuilder: $4.ReverseHex.create)
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
  $3.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($3.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $3.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.UInt64Value get valueSats => $_getN(1);
  @$pb.TagNumber(2)
  set valueSats($3.UInt64Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);
  @$pb.TagNumber(2)
  $3.UInt64Value ensureValueSats() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.UInt32Value get height => $_getN(2);
  @$pb.TagNumber(3)
  set height($3.UInt32Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
  @$pb.TagNumber(3)
  $3.UInt32Value ensureHeight() => $_ensure(2);

  @$pb.TagNumber(4)
  $4.ConsensusHex get criticalHash => $_getN(3);
  @$pb.TagNumber(4)
  set criticalHash($4.ConsensusHex v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCriticalHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearCriticalHash() => clearField(4);
  @$pb.TagNumber(4)
  $4.ConsensusHex ensureCriticalHash() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.ReverseHex get prevBytes => $_getN(4);
  @$pb.TagNumber(5)
  set prevBytes($4.ReverseHex v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrevBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevBytes() => clearField(5);
  @$pb.TagNumber(5)
  $4.ReverseHex ensurePrevBytes() => $_ensure(4);
}

class CreateBmmCriticalDataTransactionResponse extends $pb.GeneratedMessage {
  factory CreateBmmCriticalDataTransactionResponse({
    $4.ConsensusHex? txid,
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
    ..aOM<$4.ConsensusHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $4.ConsensusHex.create)
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
  $4.ConsensusHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($4.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $4.ConsensusHex ensureTxid() => $_ensure(0);
}

class CreateDepositTransactionRequest extends $pb.GeneratedMessage {
  factory CreateDepositTransactionRequest({
    $core.int? sidechainId,
    $core.String? address,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? feeSats,
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
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainId', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'valueSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
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
  $core.int get sidechainId => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get valueSats => $_getI64(2);
  @$pb.TagNumber(3)
  set valueSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);
}

class CreateDepositTransactionResponse extends $pb.GeneratedMessage {
  factory CreateDepositTransactionResponse({
    $4.ConsensusHex? txid,
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
    ..aOM<$4.ConsensusHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $4.ConsensusHex.create)
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
  $4.ConsensusHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($4.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $4.ConsensusHex ensureTxid() => $_ensure(0);
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

class GenerateBlocksRequest extends $pb.GeneratedMessage {
  factory GenerateBlocksRequest({
    $3.UInt32Value? blocks,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks = blocks;
    }
    return $result;
  }
  GenerateBlocksRequest._() : super();
  factory GenerateBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$3.UInt32Value>(1, _omitFieldNames ? '' : 'blocks', subBuilder: $3.UInt32Value.create)
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

  @$pb.TagNumber(1)
  $3.UInt32Value get blocks => $_getN(0);
  @$pb.TagNumber(1)
  set blocks($3.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);
  @$pb.TagNumber(1)
  $3.UInt32Value ensureBlocks() => $_ensure(0);
}

class GenerateBlocksResponse extends $pb.GeneratedMessage {
  factory GenerateBlocksResponse() => create();
  GenerateBlocksResponse._() : super();
  factory GenerateBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
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
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
