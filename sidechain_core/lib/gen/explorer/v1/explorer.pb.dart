//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
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

import 'explorer.pbenum.dart';

export 'explorer.pbenum.dart';

/// Block is one sidechain block.
class Block extends $pb.GeneratedMessage {
  factory Block({
    $core.int? height,
    $core.String? hash,
    $core.String? prevHash,
    $core.String? merkleRoot,
    $core.String? mainchainHash,
    $core.int? mainchainHeight,
    $fixnum.Int64? blockTime,
    $core.int? txCount,
    $fixnum.Int64? feesSats,
    $fixnum.Int64? sizeBytes,
    $core.bool? feesKnown,
    $fixnum.Int64? valueSats,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (prevHash != null) {
      $result.prevHash = prevHash;
    }
    if (merkleRoot != null) {
      $result.merkleRoot = merkleRoot;
    }
    if (mainchainHash != null) {
      $result.mainchainHash = mainchainHash;
    }
    if (mainchainHeight != null) {
      $result.mainchainHeight = mainchainHeight;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (txCount != null) {
      $result.txCount = txCount;
    }
    if (feesSats != null) {
      $result.feesSats = feesSats;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (feesKnown != null) {
      $result.feesKnown = feesKnown;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    return $result;
  }
  Block._() : super();
  factory Block.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Block.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aOS(3, _omitFieldNames ? '' : 'prevHash')
    ..aOS(4, _omitFieldNames ? '' : 'merkleRoot')
    ..aOS(5, _omitFieldNames ? '' : 'mainchainHash')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'mainchainHeight', $pb.PbFieldType.OU3)
    ..aInt64(7, _omitFieldNames ? '' : 'blockTime')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.OU3)
    ..aInt64(9, _omitFieldNames ? '' : 'feesSats')
    ..aInt64(10, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(11, _omitFieldNames ? '' : 'feesKnown')
    ..aInt64(12, _omitFieldNames ? '' : 'valueSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Block clone() => Block()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block create() => Block._();
  Block createEmptyInstance() => create();
  static $pb.PbList<Block> createRepeated() => $pb.PbList<Block>();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(create);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get merkleRoot => $_getSZ(3);
  @$pb.TagNumber(4)
  set merkleRoot($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMerkleRoot() => $_has(3);
  @$pb.TagNumber(4)
  void clearMerkleRoot() => clearField(4);

  /// mainchain_hash is the mainchain block this header merge mined against.
  @$pb.TagNumber(5)
  $core.String get mainchainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set mainchainHash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMainchainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearMainchainHash() => clearField(5);

  /// mainchain_height is the height of that block. It is zero when no enforcer
  /// resolved it.
  @$pb.TagNumber(6)
  $core.int get mainchainHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set mainchainHeight($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMainchainHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearMainchainHeight() => clearField(6);

  /// block_time comes from the mainchain block, because a sidechain header
  /// carries no clock. It is zero when no source resolved it.
  @$pb.TagNumber(7)
  $fixnum.Int64 get blockTime => $_getI64(6);
  @$pb.TagNumber(7)
  set blockTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get txCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set txCount($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTxCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearTxCount() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get feesSats => $_getI64(8);
  @$pb.TagNumber(9)
  set feesSats($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFeesSats() => $_has(8);
  @$pb.TagNumber(9)
  void clearFeesSats() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get sizeBytes => $_getI64(9);
  @$pb.TagNumber(10)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSizeBytes() => $_has(9);
  @$pb.TagNumber(10)
  void clearSizeBytes() => clearField(10);

  /// fees_known is false when the source cannot compute the fees. A node holds
  /// no previous outputs, so it never knows what a mined block collected.
  @$pb.TagNumber(11)
  $core.bool get feesKnown => $_getBF(10);
  @$pb.TagNumber(11)
  set feesKnown($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFeesKnown() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeesKnown() => clearField(11);

  /// value_sats is what the block's transactions paid out together.
  @$pb.TagNumber(12)
  $fixnum.Int64 get valueSats => $_getI64(11);
  @$pb.TagNumber(12)
  set valueSats($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasValueSats() => $_has(11);
  @$pb.TagNumber(12)
  void clearValueSats() => clearField(12);
}

/// Activity is one thing that happened on the chain.
class Activity extends $pb.GeneratedMessage {
  factory Activity({
    Kind? kind,
    $core.String? id,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? sizeBytes,
    $core.bool? confirmed,
    $core.int? blockHeight,
    $fixnum.Int64? blockTime,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (id != null) {
      $result.id = id;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    return $result;
  }
  Activity._() : super();
  factory Activity.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Activity.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Activity', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..e<Kind>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: Kind.KIND_UNSPECIFIED, valueOf: Kind.valueOf, enumValues: Kind.values)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aInt64(3, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(5, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(6, _omitFieldNames ? '' : 'confirmed')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.OU3)
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Activity clone() => Activity()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Activity copyWith(void Function(Activity) updates) => super.copyWith((message) => updates(message as Activity)) as Activity;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Activity create() => Activity._();
  Activity createEmptyInstance() => create();
  static $pb.PbList<Activity> createRepeated() => $pb.PbList<Activity>();
  @$core.pragma('dart2js:noInline')
  static Activity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Activity>(create);
  static Activity? _defaultInstance;

  @$pb.TagNumber(1)
  Kind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(Kind v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  /// id is the txid. A deposit carries its mainchain txid.
  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

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

  @$pb.TagNumber(5)
  $fixnum.Int64 get sizeBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSizeBytes() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get confirmed => $_getBF(5);
  @$pb.TagNumber(6)
  set confirmed($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasConfirmed() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmed() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get blockHeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set blockHeight($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHeight() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => clearField(8);
}

/// Coin is one input or one output.
class Coin extends $pb.GeneratedMessage {
  factory Coin({
    $core.String? address,
    $fixnum.Int64? valueSats,
    $core.String? outpointKind,
    $core.String? contentType,
    $core.String? mainAddress,
    $fixnum.Int64? mainFeeSats,
    $core.String? txid,
    $core.int? vout,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (outpointKind != null) {
      $result.outpointKind = outpointKind;
    }
    if (contentType != null) {
      $result.contentType = contentType;
    }
    if (mainAddress != null) {
      $result.mainAddress = mainAddress;
    }
    if (mainFeeSats != null) {
      $result.mainFeeSats = mainFeeSats;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    return $result;
  }
  Coin._() : super();
  factory Coin.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Coin.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Coin', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'outpointKind')
    ..aOS(4, _omitFieldNames ? '' : 'contentType')
    ..aOS(5, _omitFieldNames ? '' : 'mainAddress')
    ..aInt64(6, _omitFieldNames ? '' : 'mainFeeSats')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Coin clone() => Coin()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Coin copyWith(void Function(Coin) updates) => super.copyWith((message) => updates(message as Coin)) as Coin;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Coin create() => Coin._();
  Coin createEmptyInstance() => create();
  static $pb.PbList<Coin> createRepeated() => $pb.PbList<Coin>();
  @$core.pragma('dart2js:noInline')
  static Coin getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Coin>(create);
  static Coin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  /// outpoint_kind reads "regular", "coinbase" or "deposit".
  @$pb.TagNumber(3)
  $core.String get outpointKind => $_getSZ(2);
  @$pb.TagNumber(3)
  set outpointKind($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOutpointKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutpointKind() => clearField(3);

  /// content_type reads "value" or "withdrawal".
  @$pb.TagNumber(4)
  $core.String get contentType => $_getSZ(3);
  @$pb.TagNumber(4)
  set contentType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContentType() => $_has(3);
  @$pb.TagNumber(4)
  void clearContentType() => clearField(4);

  /// main_address and main_fee_sats are set on a withdrawal output only.
  @$pb.TagNumber(5)
  $core.String get mainAddress => $_getSZ(4);
  @$pb.TagNumber(5)
  set mainAddress($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMainAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearMainAddress() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get mainFeeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set mainFeeSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMainFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearMainFeeSats() => clearField(6);

  /// txid and vout name the coin this input spent.
  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get vout => $_getIZ(7);
  @$pb.TagNumber(8)
  set vout($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasVout() => $_has(7);
  @$pb.TagNumber(8)
  void clearVout() => clearField(8);
}

/// Transaction is one transaction and the coins on both sides.
class Transaction extends $pb.GeneratedMessage {
  factory Transaction({
    $core.String? txid,
    Kind? kind,
    $fixnum.Int64? feeSats,
    $fixnum.Int64? sizeBytes,
    $core.bool? confirmed,
    $core.int? blockHeight,
    $core.String? blockHash,
    $fixnum.Int64? blockTime,
    $core.Iterable<Coin>? inputs,
    $core.Iterable<Coin>? outputs,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    return $result;
  }
  Transaction._() : super();
  factory Transaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Transaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Transaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..e<Kind>(2, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: Kind.KIND_UNSPECIFIED, valueOf: Kind.valueOf, enumValues: Kind.values)
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'confirmed')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'blockHash')
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..pc<Coin>(9, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Coin.create)
    ..pc<Coin>(10, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Coin.create)
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
  Kind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(Kind v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get confirmed => $_getBF(4);
  @$pb.TagNumber(5)
  set confirmed($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmed() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmed() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get blockHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set blockHeight($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get blockHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set blockHash($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHash() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<Coin> get inputs => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<Coin> get outputs => $_getList(9);
}

/// Treasury is what the mainchain escrow holds for this slot.
class Treasury extends $pb.GeneratedMessage {
  factory Treasury({
    $core.int? slot,
    $fixnum.Int64? balanceSats,
    $core.String? ctipTxid,
    $core.int? ctipVout,
    $core.int? activationHeight,
  }) {
    final $result = create();
    if (slot != null) {
      $result.slot = slot;
    }
    if (balanceSats != null) {
      $result.balanceSats = balanceSats;
    }
    if (ctipTxid != null) {
      $result.ctipTxid = ctipTxid;
    }
    if (ctipVout != null) {
      $result.ctipVout = ctipVout;
    }
    if (activationHeight != null) {
      $result.activationHeight = activationHeight;
    }
    return $result;
  }
  Treasury._() : super();
  factory Treasury.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Treasury.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Treasury', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'balanceSats')
    ..aOS(3, _omitFieldNames ? '' : 'ctipTxid')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'ctipVout', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'activationHeight', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Treasury clone() => Treasury()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Treasury copyWith(void Function(Treasury) updates) => super.copyWith((message) => updates(message as Treasury)) as Treasury;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Treasury create() => Treasury._();
  Treasury createEmptyInstance() => create();
  static $pb.PbList<Treasury> createRepeated() => $pb.PbList<Treasury>();
  @$core.pragma('dart2js:noInline')
  static Treasury getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Treasury>(create);
  static Treasury? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get balanceSats => $_getI64(1);
  @$pb.TagNumber(2)
  set balanceSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBalanceSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalanceSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get ctipTxid => $_getSZ(2);
  @$pb.TagNumber(3)
  set ctipTxid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCtipTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearCtipTxid() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get ctipVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set ctipVout($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCtipVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearCtipVout() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get activationHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set activationHeight($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasActivationHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearActivationHeight() => clearField(5);
}

/// Mempool counts what waits for the next block.
class Mempool extends $pb.GeneratedMessage {
  factory Mempool({
    $core.int? txCount,
    $fixnum.Int64? feesSats,
    $fixnum.Int64? sizeBytes,
  }) {
    final $result = create();
    if (txCount != null) {
      $result.txCount = txCount;
    }
    if (feesSats != null) {
      $result.feesSats = feesSats;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    return $result;
  }
  Mempool._() : super();
  factory Mempool.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Mempool.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Mempool', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'feesSats')
    ..aInt64(3, _omitFieldNames ? '' : 'sizeBytes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Mempool clone() => Mempool()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Mempool copyWith(void Function(Mempool) updates) => super.copyWith((message) => updates(message as Mempool)) as Mempool;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Mempool create() => Mempool._();
  Mempool createEmptyInstance() => create();
  static $pb.PbList<Mempool> createRepeated() => $pb.PbList<Mempool>();
  @$core.pragma('dart2js:noInline')
  static Mempool getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mempool>(create);
  static Mempool? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get txCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set txCount($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxCount() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feesSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feesSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeesSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeesSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sizeBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSizeBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearSizeBytes() => clearField(3);
}

class GetOverviewRequest extends $pb.GeneratedMessage {
  factory GetOverviewRequest({
    $core.String? chain,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    return $result;
  }
  GetOverviewRequest._() : super();
  factory GetOverviewRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetOverviewRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOverviewRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetOverviewRequest clone() => GetOverviewRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetOverviewRequest copyWith(void Function(GetOverviewRequest) updates) => super.copyWith((message) => updates(message as GetOverviewRequest)) as GetOverviewRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOverviewRequest create() => GetOverviewRequest._();
  GetOverviewRequest createEmptyInstance() => create();
  static $pb.PbList<GetOverviewRequest> createRepeated() => $pb.PbList<GetOverviewRequest>();
  @$core.pragma('dart2js:noInline')
  static GetOverviewRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOverviewRequest>(create);
  static GetOverviewRequest? _defaultInstance;

  /// chain is the sidechain name, as the chain registry writes it.
  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);
}

class GetOverviewResponse extends $pb.GeneratedMessage {
  factory GetOverviewResponse({
    $core.Iterable<Block>? blocks,
    $core.Iterable<Activity>? recent,
    Mempool? mempool,
    Treasury? treasury,
    WithdrawalBundle? pendingBundle,
    $core.int? tipHeight,
    $core.String? source,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks.addAll(blocks);
    }
    if (recent != null) {
      $result.recent.addAll(recent);
    }
    if (mempool != null) {
      $result.mempool = mempool;
    }
    if (treasury != null) {
      $result.treasury = treasury;
    }
    if (pendingBundle != null) {
      $result.pendingBundle = pendingBundle;
    }
    if (tipHeight != null) {
      $result.tipHeight = tipHeight;
    }
    if (source != null) {
      $result.source = source;
    }
    return $result;
  }
  GetOverviewResponse._() : super();
  factory GetOverviewResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetOverviewResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOverviewResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..pc<Block>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.PM, subBuilder: Block.create)
    ..pc<Activity>(2, _omitFieldNames ? '' : 'recent', $pb.PbFieldType.PM, subBuilder: Activity.create)
    ..aOM<Mempool>(3, _omitFieldNames ? '' : 'mempool', subBuilder: Mempool.create)
    ..aOM<Treasury>(4, _omitFieldNames ? '' : 'treasury', subBuilder: Treasury.create)
    ..aOM<WithdrawalBundle>(5, _omitFieldNames ? '' : 'pendingBundle', subBuilder: WithdrawalBundle.create)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'tipHeight', $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'source')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetOverviewResponse clone() => GetOverviewResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetOverviewResponse copyWith(void Function(GetOverviewResponse) updates) => super.copyWith((message) => updates(message as GetOverviewResponse)) as GetOverviewResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOverviewResponse create() => GetOverviewResponse._();
  GetOverviewResponse createEmptyInstance() => create();
  static $pb.PbList<GetOverviewResponse> createRepeated() => $pb.PbList<GetOverviewResponse>();
  @$core.pragma('dart2js:noInline')
  static GetOverviewResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOverviewResponse>(create);
  static GetOverviewResponse? _defaultInstance;

  /// blocks are newest first.
  @$pb.TagNumber(1)
  $core.List<Block> get blocks => $_getList(0);

  /// recent is newest first, and the unconfirmed rows come before the rest.
  @$pb.TagNumber(2)
  $core.List<Activity> get recent => $_getList(1);

  @$pb.TagNumber(3)
  Mempool get mempool => $_getN(2);
  @$pb.TagNumber(3)
  set mempool(Mempool v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMempool() => $_has(2);
  @$pb.TagNumber(3)
  void clearMempool() => clearField(3);
  @$pb.TagNumber(3)
  Mempool ensureMempool() => $_ensure(2);

  @$pb.TagNumber(4)
  Treasury get treasury => $_getN(3);
  @$pb.TagNumber(4)
  set treasury(Treasury v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTreasury() => $_has(3);
  @$pb.TagNumber(4)
  void clearTreasury() => clearField(4);
  @$pb.TagNumber(4)
  Treasury ensureTreasury() => $_ensure(3);

  @$pb.TagNumber(5)
  WithdrawalBundle get pendingBundle => $_getN(4);
  @$pb.TagNumber(5)
  set pendingBundle(WithdrawalBundle v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPendingBundle() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingBundle() => clearField(5);
  @$pb.TagNumber(5)
  WithdrawalBundle ensurePendingBundle() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get tipHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set tipHeight($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTipHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearTipHeight() => clearField(6);

  /// source reads "index" or "node", so a reader knows what answered.
  @$pb.TagNumber(7)
  $core.String get source => $_getSZ(6);
  @$pb.TagNumber(7)
  set source($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSource() => $_has(6);
  @$pb.TagNumber(7)
  void clearSource() => clearField(7);
}

class ListBlocksRequest extends $pb.GeneratedMessage {
  factory ListBlocksRequest({
    $core.String? chain,
    $core.int? beforeHeight,
    $core.int? limit,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (beforeHeight != null) {
      $result.beforeHeight = beforeHeight;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ListBlocksRequest._() : super();
  factory ListBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'beforeHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksRequest clone() => ListBlocksRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksRequest copyWith(void Function(ListBlocksRequest) updates) => super.copyWith((message) => updates(message as ListBlocksRequest)) as ListBlocksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest create() => ListBlocksRequest._();
  ListBlocksRequest createEmptyInstance() => create();
  static $pb.PbList<ListBlocksRequest> createRepeated() => $pb.PbList<ListBlocksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksRequest>(create);
  static ListBlocksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  /// before_height starts the page at this height and reads down. Leave it
  /// empty to start at the tip.
  @$pb.TagNumber(2)
  $core.int get beforeHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set beforeHeight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBeforeHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeforeHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => clearField(3);
}

class ListBlocksResponse extends $pb.GeneratedMessage {
  factory ListBlocksResponse({
    $core.Iterable<Block>? blocks,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks.addAll(blocks);
    }
    return $result;
  }
  ListBlocksResponse._() : super();
  factory ListBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..pc<Block>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.PM, subBuilder: Block.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksResponse clone() => ListBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksResponse copyWith(void Function(ListBlocksResponse) updates) => super.copyWith((message) => updates(message as ListBlocksResponse)) as ListBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse create() => ListBlocksResponse._();
  ListBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<ListBlocksResponse> createRepeated() => $pb.PbList<ListBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksResponse>(create);
  static ListBlocksResponse? _defaultInstance;

  /// blocks are newest first. A page shorter than the limit is the last one.
  @$pb.TagNumber(1)
  $core.List<Block> get blocks => $_getList(0);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? chain,
    $core.String? hash,
    $core.int? height,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  GetBlockRequest._() : super();
  factory GetBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockRequest clone() => GetBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) => super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockRequest create() => GetBlockRequest._();
  GetBlockRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockRequest> createRepeated() => $pb.PbList<GetBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(create);
  static GetBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  /// Name one of these. A hash wins when both arrive.
  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    Block? block,
    $core.Iterable<Activity>? activity,
  }) {
    final $result = create();
    if (block != null) {
      $result.block = block;
    }
    if (activity != null) {
      $result.activity.addAll(activity);
    }
    return $result;
  }
  GetBlockResponse._() : super();
  factory GetBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOM<Block>(1, _omitFieldNames ? '' : 'block', subBuilder: Block.create)
    ..pc<Activity>(2, _omitFieldNames ? '' : 'activity', $pb.PbFieldType.PM, subBuilder: Activity.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockResponse clone() => GetBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) => super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockResponse create() => GetBlockResponse._();
  GetBlockResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockResponse> createRepeated() => $pb.PbList<GetBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(create);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Block get block => $_getN(0);
  @$pb.TagNumber(1)
  set block(Block v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlock() => clearField(1);
  @$pb.TagNumber(1)
  Block ensureBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<Activity> get activity => $_getList(1);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? chain,
    $core.String? txid,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionRequest._() : super();
  factory GetTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionRequest clone() => GetTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionRequest copyWith(void Function(GetTransactionRequest) updates) => super.copyWith((message) => updates(message as GetTransactionRequest)) as GetTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest create() => GetTransactionRequest._();
  GetTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionRequest> createRepeated() => $pb.PbList<GetTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(create);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    Transaction? transaction,
  }) {
    final $result = create();
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  GetTransactionResponse._() : super();
  factory GetTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOM<Transaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: Transaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionResponse clone() => GetTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionResponse copyWith(void Function(GetTransactionResponse) updates) => super.copyWith((message) => updates(message as GetTransactionResponse)) as GetTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse create() => GetTransactionResponse._();
  GetTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionResponse> createRepeated() => $pb.PbList<GetTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(create);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Transaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(Transaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => clearField(1);
  @$pb.TagNumber(1)
  Transaction ensureTransaction() => $_ensure(0);
}

class GetAddressRequest extends $pb.GeneratedMessage {
  factory GetAddressRequest({
    $core.String? chain,
    $core.String? address,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetAddressRequest._() : super();
  factory GetAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressRequest clone() => GetAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressRequest copyWith(void Function(GetAddressRequest) updates) => super.copyWith((message) => updates(message as GetAddressRequest)) as GetAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressRequest create() => GetAddressRequest._();
  GetAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetAddressRequest> createRepeated() => $pb.PbList<GetAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressRequest>(create);
  static GetAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);
}

class GetAddressResponse extends $pb.GeneratedMessage {
  factory GetAddressResponse({
    $core.String? address,
    $fixnum.Int64? confirmedBalanceSats,
    $fixnum.Int64? unconfirmedBalanceSats,
    $fixnum.Int64? totalReceivedSats,
    $core.int? confirmedCoinCount,
    $core.int? unconfirmedCoinCount,
    $core.int? txCount,
    $core.Iterable<Transaction>? transactions,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (confirmedBalanceSats != null) {
      $result.confirmedBalanceSats = confirmedBalanceSats;
    }
    if (unconfirmedBalanceSats != null) {
      $result.unconfirmedBalanceSats = unconfirmedBalanceSats;
    }
    if (totalReceivedSats != null) {
      $result.totalReceivedSats = totalReceivedSats;
    }
    if (confirmedCoinCount != null) {
      $result.confirmedCoinCount = confirmedCoinCount;
    }
    if (unconfirmedCoinCount != null) {
      $result.unconfirmedCoinCount = unconfirmedCoinCount;
    }
    if (txCount != null) {
      $result.txCount = txCount;
    }
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  GetAddressResponse._() : super();
  factory GetAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'confirmedBalanceSats')
    ..aInt64(3, _omitFieldNames ? '' : 'unconfirmedBalanceSats')
    ..aInt64(4, _omitFieldNames ? '' : 'totalReceivedSats')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmedCoinCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'unconfirmedCoinCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.OU3)
    ..pc<Transaction>(8, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: Transaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressResponse clone() => GetAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressResponse copyWith(void Function(GetAddressResponse) updates) => super.copyWith((message) => updates(message as GetAddressResponse)) as GetAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressResponse create() => GetAddressResponse._();
  GetAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetAddressResponse> createRepeated() => $pb.PbList<GetAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressResponse>(create);
  static GetAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get confirmedBalanceSats => $_getI64(1);
  @$pb.TagNumber(2)
  set confirmedBalanceSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConfirmedBalanceSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmedBalanceSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get unconfirmedBalanceSats => $_getI64(2);
  @$pb.TagNumber(3)
  set unconfirmedBalanceSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUnconfirmedBalanceSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnconfirmedBalanceSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalReceivedSats => $_getI64(3);
  @$pb.TagNumber(4)
  set totalReceivedSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalReceivedSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalReceivedSats() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmedCoinCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmedCoinCount($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmedCoinCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedCoinCount() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get unconfirmedCoinCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set unconfirmedCoinCount($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUnconfirmedCoinCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnconfirmedCoinCount() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get txCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set txCount($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxCount() => clearField(7);

  /// transactions are newest first, unconfirmed first.
  @$pb.TagNumber(8)
  $core.List<Transaction> get transactions => $_getList(7);
}

/// Withdrawal is one payout inside a bundle.
class Withdrawal extends $pb.GeneratedMessage {
  factory Withdrawal({
    $core.String? mainAddress,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? mainFeeSats,
    $core.int? cumulativeWeight,
  }) {
    final $result = create();
    if (mainAddress != null) {
      $result.mainAddress = mainAddress;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (mainFeeSats != null) {
      $result.mainFeeSats = mainFeeSats;
    }
    if (cumulativeWeight != null) {
      $result.cumulativeWeight = cumulativeWeight;
    }
    return $result;
  }
  Withdrawal._() : super();
  factory Withdrawal.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Withdrawal.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Withdrawal', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mainAddress')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(3, _omitFieldNames ? '' : 'mainFeeSats')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'cumulativeWeight', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Withdrawal clone() => Withdrawal()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Withdrawal copyWith(void Function(Withdrawal) updates) => super.copyWith((message) => updates(message as Withdrawal)) as Withdrawal;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Withdrawal create() => Withdrawal._();
  Withdrawal createEmptyInstance() => create();
  static $pb.PbList<Withdrawal> createRepeated() => $pb.PbList<Withdrawal>();
  @$core.pragma('dart2js:noInline')
  static Withdrawal getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Withdrawal>(create);
  static Withdrawal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mainAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set mainAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMainAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get mainFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set mainFeeSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMainFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearMainFeeSats() => clearField(3);

  /// cumulative_weight counts this withdrawal and every one before it in the
  /// bundle, against max_weight.
  @$pb.TagNumber(4)
  $core.int get cumulativeWeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set cumulativeWeight($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCumulativeWeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearCumulativeWeight() => clearField(4);
}

/// WithdrawalBundle is the bundle a chain proposes to the mainchain.
class WithdrawalBundle extends $pb.GeneratedMessage {
  factory WithdrawalBundle({
    $core.bool? present,
    $core.String? m6id,
    $core.int? heightCreated,
    $fixnum.Int64? totalValueSats,
    $fixnum.Int64? totalMainFeesSats,
    $core.int? totalWeight,
    $core.int? maxWeight,
    $core.Iterable<Withdrawal>? withdrawals,
  }) {
    final $result = create();
    if (present != null) {
      $result.present = present;
    }
    if (m6id != null) {
      $result.m6id = m6id;
    }
    if (heightCreated != null) {
      $result.heightCreated = heightCreated;
    }
    if (totalValueSats != null) {
      $result.totalValueSats = totalValueSats;
    }
    if (totalMainFeesSats != null) {
      $result.totalMainFeesSats = totalMainFeesSats;
    }
    if (totalWeight != null) {
      $result.totalWeight = totalWeight;
    }
    if (maxWeight != null) {
      $result.maxWeight = maxWeight;
    }
    if (withdrawals != null) {
      $result.withdrawals.addAll(withdrawals);
    }
    return $result;
  }
  WithdrawalBundle._() : super();
  factory WithdrawalBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'present')
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'heightCreated', $pb.PbFieldType.OU3)
    ..aInt64(4, _omitFieldNames ? '' : 'totalValueSats')
    ..aInt64(5, _omitFieldNames ? '' : 'totalMainFeesSats')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'totalWeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'maxWeight', $pb.PbFieldType.OU3)
    ..pc<Withdrawal>(8, _omitFieldNames ? '' : 'withdrawals', $pb.PbFieldType.PM, subBuilder: Withdrawal.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundle clone() => WithdrawalBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundle copyWith(void Function(WithdrawalBundle) updates) => super.copyWith((message) => updates(message as WithdrawalBundle)) as WithdrawalBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle create() => WithdrawalBundle._();
  WithdrawalBundle createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundle> createRepeated() => $pb.PbList<WithdrawalBundle>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundle>(create);
  static WithdrawalBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get present => $_getBF(0);
  @$pb.TagNumber(1)
  set present($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPresent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPresent() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get heightCreated => $_getIZ(2);
  @$pb.TagNumber(3)
  set heightCreated($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeightCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeightCreated() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalValueSats => $_getI64(3);
  @$pb.TagNumber(4)
  set totalValueSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalValueSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalValueSats() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalMainFeesSats => $_getI64(4);
  @$pb.TagNumber(5)
  set totalMainFeesSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalMainFeesSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalMainFeesSats() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalWeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalWeight($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalWeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalWeight() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxWeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxWeight($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMaxWeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxWeight() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<Withdrawal> get withdrawals => $_getList(7);
}

class GetWithdrawalsRequest extends $pb.GeneratedMessage {
  factory GetWithdrawalsRequest({
    $core.String? chain,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    return $result;
  }
  GetWithdrawalsRequest._() : super();
  factory GetWithdrawalsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWithdrawalsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWithdrawalsRequest clone() => GetWithdrawalsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWithdrawalsRequest copyWith(void Function(GetWithdrawalsRequest) updates) => super.copyWith((message) => updates(message as GetWithdrawalsRequest)) as GetWithdrawalsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsRequest create() => GetWithdrawalsRequest._();
  GetWithdrawalsRequest createEmptyInstance() => create();
  static $pb.PbList<GetWithdrawalsRequest> createRepeated() => $pb.PbList<GetWithdrawalsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWithdrawalsRequest>(create);
  static GetWithdrawalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);
}

class GetWithdrawalsResponse extends $pb.GeneratedMessage {
  factory GetWithdrawalsResponse({
    WithdrawalBundle? bundle,
    $core.int? lastFailedHeight,
  }) {
    final $result = create();
    if (bundle != null) {
      $result.bundle = bundle;
    }
    if (lastFailedHeight != null) {
      $result.lastFailedHeight = lastFailedHeight;
    }
    return $result;
  }
  GetWithdrawalsResponse._() : super();
  factory GetWithdrawalsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWithdrawalsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOM<WithdrawalBundle>(1, _omitFieldNames ? '' : 'bundle', subBuilder: WithdrawalBundle.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'lastFailedHeight', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWithdrawalsResponse clone() => GetWithdrawalsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWithdrawalsResponse copyWith(void Function(GetWithdrawalsResponse) updates) => super.copyWith((message) => updates(message as GetWithdrawalsResponse)) as GetWithdrawalsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsResponse create() => GetWithdrawalsResponse._();
  GetWithdrawalsResponse createEmptyInstance() => create();
  static $pb.PbList<GetWithdrawalsResponse> createRepeated() => $pb.PbList<GetWithdrawalsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWithdrawalsResponse>(create);
  static GetWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalBundle get bundle => $_getN(0);
  @$pb.TagNumber(1)
  set bundle(WithdrawalBundle v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBundle() => $_has(0);
  @$pb.TagNumber(1)
  void clearBundle() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalBundle ensureBundle() => $_ensure(0);

  /// last_failed_height is the sidechain height of the last bundle the
  /// mainchain rejected. It is zero when none ever failed.
  @$pb.TagNumber(2)
  $core.int get lastFailedHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastFailedHeight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastFailedHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastFailedHeight() => clearField(2);
}

class ExplorerServiceApi {
  $pb.RpcClient _client;
  ExplorerServiceApi(this._client);

  $async.Future<GetOverviewResponse> getOverview($pb.ClientContext? ctx, GetOverviewRequest request) =>
    _client.invoke<GetOverviewResponse>(ctx, 'ExplorerService', 'GetOverview', request, GetOverviewResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'ExplorerService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<ListBlocksResponse> listBlocks($pb.ClientContext? ctx, ListBlocksRequest request) =>
    _client.invoke<ListBlocksResponse>(ctx, 'ExplorerService', 'ListBlocks', request, ListBlocksResponse())
  ;
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
    _client.invoke<GetTransactionResponse>(ctx, 'ExplorerService', 'GetTransaction', request, GetTransactionResponse())
  ;
  $async.Future<GetAddressResponse> getAddress($pb.ClientContext? ctx, GetAddressRequest request) =>
    _client.invoke<GetAddressResponse>(ctx, 'ExplorerService', 'GetAddress', request, GetAddressResponse())
  ;
  $async.Future<GetWithdrawalsResponse> getWithdrawals($pb.ClientContext? ctx, GetWithdrawalsRequest request) =>
    _client.invoke<GetWithdrawalsResponse>(ctx, 'ExplorerService', 'GetWithdrawals', request, GetWithdrawalsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
