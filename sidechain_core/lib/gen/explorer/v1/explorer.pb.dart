// This is a generated file - do not edit.
//
// Generated from explorer/v1/explorer.proto.

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

import 'explorer.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    $core.int? depositCount,
    $fixnum.Int64? depositValueSats,
    Bid? bid,
    $core.bool? valueKnown,
  }) {
    final result = Block._();
    if (height != null) result.height = height;
    if (hash != null) result.hash = hash;
    if (prevHash != null) result.prevHash = prevHash;
    if (merkleRoot != null) result.merkleRoot = merkleRoot;
    if (mainchainHash != null) result.mainchainHash = mainchainHash;
    if (mainchainHeight != null) result.mainchainHeight = mainchainHeight;
    if (blockTime != null) result.blockTime = blockTime;
    if (txCount != null) result.txCount = txCount;
    if (feesSats != null) result.feesSats = feesSats;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (feesKnown != null) result.feesKnown = feesKnown;
    if (valueSats != null) result.valueSats = valueSats;
    if (depositCount != null) result.depositCount = depositCount;
    if (depositValueSats != null) result.depositValueSats = depositValueSats;
    if (bid != null) result.bid = bid;
    if (valueKnown != null) result.valueKnown = valueKnown;
    return result;
  }

  Block._();

  factory Block.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromBuffer(data, registry);
  factory Block.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Block.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aOS(3, _omitFieldNames ? '' : 'prevHash')
    ..aOS(4, _omitFieldNames ? '' : 'merkleRoot')
    ..aOS(5, _omitFieldNames ? '' : 'mainchainHash')
    ..aI(6, _omitFieldNames ? '' : 'mainchainHeight', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(7, _omitFieldNames ? '' : 'blockTime')
    ..aI(8, _omitFieldNames ? '' : 'txCount', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(9, _omitFieldNames ? '' : 'feesSats')
    ..aInt64(10, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(11, _omitFieldNames ? '' : 'feesKnown')
    ..aInt64(12, _omitFieldNames ? '' : 'valueSats')
    ..aI(13, _omitFieldNames ? '' : 'depositCount', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(14, _omitFieldNames ? '' : 'depositValueSats')
    ..aOM<Bid>(15, _omitFieldNames ? '' : 'bid', subBuilder: Bid.$_createMessage)
    ..aOB(20, _omitFieldNames ? '' : 'valueKnown')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Block() / Block.new instead')
  static Block create() => Block._();
  static $pb.GeneratedMessage $_createMessage() => Block._();
  @$core.override
  Block createEmptyInstance() => Block._();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(Block.$_createMessage);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get prevHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get merkleRoot => $_getSZ(3);
  @$pb.TagNumber(4)
  set merkleRoot($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMerkleRoot() => $_has(3);
  @$pb.TagNumber(4)
  void clearMerkleRoot() => $_clearField(4);

  /// mainchain_hash is the mainchain block this header merge mined against.
  @$pb.TagNumber(5)
  $core.String get mainchainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set mainchainHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMainchainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearMainchainHash() => $_clearField(5);

  /// mainchain_height is the height of that block. It is zero when no enforcer
  /// resolved it.
  @$pb.TagNumber(6)
  $core.int get mainchainHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set mainchainHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMainchainHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearMainchainHeight() => $_clearField(6);

  /// block_time comes from the mainchain block, because a sidechain header
  /// carries no clock. It is zero when no source resolved it.
  @$pb.TagNumber(7)
  $fixnum.Int64 get blockTime => $_getI64(6);
  @$pb.TagNumber(7)
  set blockTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get txCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set txCount($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTxCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearTxCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get feesSats => $_getI64(8);
  @$pb.TagNumber(9)
  set feesSats($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFeesSats() => $_has(8);
  @$pb.TagNumber(9)
  void clearFeesSats() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get sizeBytes => $_getI64(9);
  @$pb.TagNumber(10)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSizeBytes() => $_has(9);
  @$pb.TagNumber(10)
  void clearSizeBytes() => $_clearField(10);

  /// fees_known is false when the source cannot compute the fees. A node holds
  /// no previous outputs, so it never knows what a mined block collected.
  @$pb.TagNumber(11)
  $core.bool get feesKnown => $_getBF(10);
  @$pb.TagNumber(11)
  set feesKnown($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFeesKnown() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeesKnown() => $_clearField(11);

  /// value_sats is what the block's transactions paid out together.
  @$pb.TagNumber(12)
  $fixnum.Int64 get valueSats => $_getI64(11);
  @$pb.TagNumber(12)
  set valueSats($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasValueSats() => $_has(11);
  @$pb.TagNumber(12)
  void clearValueSats() => $_clearField(12);

  /// deposit_count and deposit_value_sats name what the mainchain paid into
  /// this block. A deposit never sits in the block body.
  @$pb.TagNumber(13)
  $core.int get depositCount => $_getIZ(12);
  @$pb.TagNumber(13)
  set depositCount($core.int value) => $_setUnsignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDepositCount() => $_has(12);
  @$pb.TagNumber(13)
  void clearDepositCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get depositValueSats => $_getI64(13);
  @$pb.TagNumber(14)
  set depositValueSats($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDepositValueSats() => $_has(13);
  @$pb.TagNumber(14)
  void clearDepositValueSats() => $_clearField(14);

  /// bid names the winning BMM bid on the mainchain: the outpoint that carried
  /// the M8, and what it paid.
  @$pb.TagNumber(15)
  Bid get bid => $_getN(14);
  @$pb.TagNumber(15)
  set bid(Bid value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasBid() => $_has(14);
  @$pb.TagNumber(15)
  void clearBid() => $_clearField(15);
  @$pb.TagNumber(15)
  Bid ensureBid() => $_ensure(14);

  /// value_known is false when the source cannot compute it. A hosted index
  /// states the fees a block collected, and never the value it moved.
  @$pb.TagNumber(20)
  $core.bool get valueKnown => $_getBF(15);
  @$pb.TagNumber(20)
  set valueKnown($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(20)
  $core.bool hasValueKnown() => $_has(15);
  @$pb.TagNumber(20)
  void clearValueKnown() => $_clearField(20);
}

/// Bid is the M8 a miner took to mine one sidechain block.
class Bid extends $pb.GeneratedMessage {
  factory Bid({
    $core.String? txid,
    $core.int? vout,
    $fixnum.Int64? sats,
    $core.String? blockHash,
    $core.int? blockHeight,
  }) {
    final result = Bid._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (sats != null) result.sats = sats;
    if (blockHash != null) result.blockHash = blockHash;
    if (blockHeight != null) result.blockHeight = blockHeight;
    return result;
  }

  Bid._();

  factory Bid.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bid()..mergeFromBuffer(data, registry);
  factory Bid.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bid()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Bid',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: Bid.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(3, _omitFieldNames ? '' : 'sats')
    ..aOS(4, _omitFieldNames ? '' : 'blockHash')
    ..aI(5, _omitFieldNames ? '' : 'blockHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bid clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bid copyWith(void Function(Bid) updates) => super.copyWith((message) => updates(message as Bid)) as Bid;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Bid() / Bid.new instead')
  static Bid create() => Bid._();
  static $pb.GeneratedMessage $_createMessage() => Bid._();
  @$core.override
  Bid createEmptyInstance() => Bid._();
  @$core.pragma('dart2js:noInline')
  static Bid getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bid>(Bid.$_createMessage);
  static Bid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  /// sats is the fee the bid paid.
  @$pb.TagNumber(3)
  $fixnum.Int64 get sats => $_getI64(2);
  @$pb.TagNumber(3)
  set sats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearSats() => $_clearField(3);

  /// block_hash and block_height name the mainchain block that carried the M8.
  /// That block is the child of the block the header names.
  @$pb.TagNumber(4)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockHash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get blockHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set blockHeight($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => $_clearField(5);
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
    $core.String? address,
  }) {
    final result = Activity._();
    if (kind != null) result.kind = kind;
    if (id != null) result.id = id;
    if (valueSats != null) result.valueSats = valueSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (confirmed != null) result.confirmed = confirmed;
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (blockTime != null) result.blockTime = blockTime;
    if (address != null) result.address = address;
    return result;
  }

  Activity._();

  factory Activity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Activity()..mergeFromBuffer(data, registry);
  factory Activity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Activity()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Activity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Activity.$_createMessage)
    ..aE<Kind>(1, _omitFieldNames ? '' : 'kind', enumValues: Kind.values)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aInt64(3, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(5, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(6, _omitFieldNames ? '' : 'confirmed')
    ..aI(7, _omitFieldNames ? '' : 'blockHeight', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..aOS(9, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Activity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Activity copyWith(void Function(Activity) updates) =>
      super.copyWith((message) => updates(message as Activity)) as Activity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Activity() / Activity.new instead')
  static Activity create() => Activity._();
  static $pb.GeneratedMessage $_createMessage() => Activity._();
  @$core.override
  Activity createEmptyInstance() => Activity._();
  @$core.pragma('dart2js:noInline')
  static Activity getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Activity>(Activity.$_createMessage);
  static Activity? _defaultInstance;

  @$pb.TagNumber(1)
  Kind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(Kind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  /// id is the txid. A deposit carries its mainchain txid.
  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get valueSats => $_getI64(2);
  @$pb.TagNumber(3)
  set valueSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get sizeBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSizeBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get confirmed => $_getBF(5);
  @$pb.TagNumber(6)
  set confirmed($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfirmed() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmed() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get blockHeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set blockHeight($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => $_clearField(8);

  /// address is the sidechain address a deposit paid. It is empty on every
  /// other kind.
  @$pb.TagNumber(9)
  $core.String get address => $_getSZ(8);
  @$pb.TagNumber(9)
  set address($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAddress() => $_has(8);
  @$pb.TagNumber(9)
  void clearAddress() => $_clearField(9);
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
    final result = Coin._();
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    if (outpointKind != null) result.outpointKind = outpointKind;
    if (contentType != null) result.contentType = contentType;
    if (mainAddress != null) result.mainAddress = mainAddress;
    if (mainFeeSats != null) result.mainFeeSats = mainFeeSats;
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    return result;
  }

  Coin._();

  factory Coin.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Coin()..mergeFromBuffer(data, registry);
  factory Coin.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Coin()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Coin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: Coin.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'outpointKind')
    ..aOS(4, _omitFieldNames ? '' : 'contentType')
    ..aOS(5, _omitFieldNames ? '' : 'mainAddress')
    ..aInt64(6, _omitFieldNames ? '' : 'mainFeeSats')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..aI(8, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Coin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Coin copyWith(void Function(Coin) updates) => super.copyWith((message) => updates(message as Coin)) as Coin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Coin() / Coin.new instead')
  static Coin create() => Coin._();
  static $pb.GeneratedMessage $_createMessage() => Coin._();
  @$core.override
  Coin createEmptyInstance() => Coin._();
  @$core.pragma('dart2js:noInline')
  static Coin getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Coin>(Coin.$_createMessage);
  static Coin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  /// value_sats is the payout. A withdrawal costs this and main_fee_sats
  /// together.
  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  /// outpoint_kind reads "regular", "coinbase" or "deposit".
  @$pb.TagNumber(3)
  $core.String get outpointKind => $_getSZ(2);
  @$pb.TagNumber(3)
  set outpointKind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOutpointKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutpointKind() => $_clearField(3);

  /// content_type reads "value" or "withdrawal".
  @$pb.TagNumber(4)
  $core.String get contentType => $_getSZ(3);
  @$pb.TagNumber(4)
  set contentType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContentType() => $_has(3);
  @$pb.TagNumber(4)
  void clearContentType() => $_clearField(4);

  /// main_address and main_fee_sats are set on a withdrawal output only.
  @$pb.TagNumber(5)
  $core.String get mainAddress => $_getSZ(4);
  @$pb.TagNumber(5)
  set mainAddress($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMainAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearMainAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get mainFeeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set mainFeeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMainFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearMainFeeSats() => $_clearField(6);

  /// txid and vout name the coin this input spent.
  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get vout => $_getIZ(7);
  @$pb.TagNumber(8)
  set vout($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVout() => $_has(7);
  @$pb.TagNumber(8)
  void clearVout() => $_clearField(8);
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
    final result = Transaction._();
    if (txid != null) result.txid = txid;
    if (kind != null) result.kind = kind;
    if (feeSats != null) result.feeSats = feeSats;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (confirmed != null) result.confirmed = confirmed;
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (blockHash != null) result.blockHash = blockHash;
    if (blockTime != null) result.blockTime = blockTime;
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    return result;
  }

  Transaction._();

  factory Transaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromBuffer(data, registry);
  factory Transaction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Transaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Transaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aE<Kind>(2, _omitFieldNames ? '' : 'kind', enumValues: Kind.values)
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'confirmed')
    ..aI(6, _omitFieldNames ? '' : 'blockHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'blockHash')
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..pPM<Coin>(9, _omitFieldNames ? '' : 'inputs', subBuilder: Coin.$_createMessage)
    ..pPM<Coin>(10, _omitFieldNames ? '' : 'outputs', subBuilder: Coin.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction copyWith(void Function(Transaction) updates) =>
      super.copyWith((message) => updates(message as Transaction)) as Transaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Transaction() / Transaction.new instead')
  static Transaction create() => Transaction._();
  static $pb.GeneratedMessage $_createMessage() => Transaction._();
  @$core.override
  Transaction createEmptyInstance() => Transaction._();
  @$core.pragma('dart2js:noInline')
  static Transaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Transaction>(Transaction.$_createMessage);
  static Transaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  Kind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(Kind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get confirmed => $_getBF(4);
  @$pb.TagNumber(5)
  set confirmed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmed() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get blockHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set blockHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get blockHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set blockHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHash() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<Coin> get inputs => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<Coin> get outputs => $_getList(9);
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
    final result = Treasury._();
    if (slot != null) result.slot = slot;
    if (balanceSats != null) result.balanceSats = balanceSats;
    if (ctipTxid != null) result.ctipTxid = ctipTxid;
    if (ctipVout != null) result.ctipVout = ctipVout;
    if (activationHeight != null) result.activationHeight = activationHeight;
    return result;
  }

  Treasury._();

  factory Treasury.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Treasury()..mergeFromBuffer(data, registry);
  factory Treasury.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Treasury()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Treasury',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Treasury.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'balanceSats')
    ..aOS(3, _omitFieldNames ? '' : 'ctipTxid')
    ..aI(4, _omitFieldNames ? '' : 'ctipVout', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'activationHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Treasury clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Treasury copyWith(void Function(Treasury) updates) =>
      super.copyWith((message) => updates(message as Treasury)) as Treasury;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Treasury() / Treasury.new instead')
  static Treasury create() => Treasury._();
  static $pb.GeneratedMessage $_createMessage() => Treasury._();
  @$core.override
  Treasury createEmptyInstance() => Treasury._();
  @$core.pragma('dart2js:noInline')
  static Treasury getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Treasury>(Treasury.$_createMessage);
  static Treasury? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get balanceSats => $_getI64(1);
  @$pb.TagNumber(2)
  set balanceSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBalanceSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalanceSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ctipTxid => $_getSZ(2);
  @$pb.TagNumber(3)
  set ctipTxid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCtipTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearCtipTxid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get ctipVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set ctipVout($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCtipVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearCtipVout() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get activationHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set activationHeight($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActivationHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearActivationHeight() => $_clearField(5);
}

/// Mempool counts what waits for the next block.
class Mempool extends $pb.GeneratedMessage {
  factory Mempool({
    $core.int? txCount,
    $fixnum.Int64? feesSats,
    $fixnum.Int64? sizeBytes,
  }) {
    final result = Mempool._();
    if (txCount != null) result.txCount = txCount;
    if (feesSats != null) result.feesSats = feesSats;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    return result;
  }

  Mempool._();

  factory Mempool.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Mempool()..mergeFromBuffer(data, registry);
  factory Mempool.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Mempool()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Mempool',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Mempool.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'txCount', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'feesSats')
    ..aInt64(3, _omitFieldNames ? '' : 'sizeBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mempool clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mempool copyWith(void Function(Mempool) updates) =>
      super.copyWith((message) => updates(message as Mempool)) as Mempool;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Mempool() / Mempool.new instead')
  static Mempool create() => Mempool._();
  static $pb.GeneratedMessage $_createMessage() => Mempool._();
  @$core.override
  Mempool createEmptyInstance() => Mempool._();
  @$core.pragma('dart2js:noInline')
  static Mempool getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mempool>(Mempool.$_createMessage);
  static Mempool? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get txCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set txCount($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feesSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feesSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeesSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeesSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sizeBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSizeBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearSizeBytes() => $_clearField(3);
}

class GetOverviewRequest extends $pb.GeneratedMessage {
  factory GetOverviewRequest({
    $core.String? chain,
  }) {
    final result = GetOverviewRequest._();
    if (chain != null) result.chain = chain;
    return result;
  }

  GetOverviewRequest._();

  factory GetOverviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOverviewRequest()..mergeFromBuffer(data, registry);
  factory GetOverviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOverviewRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOverviewRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetOverviewRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOverviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOverviewRequest copyWith(void Function(GetOverviewRequest) updates) =>
      super.copyWith((message) => updates(message as GetOverviewRequest)) as GetOverviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetOverviewRequest() / GetOverviewRequest.new instead')
  static GetOverviewRequest create() => GetOverviewRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetOverviewRequest._();
  @$core.override
  GetOverviewRequest createEmptyInstance() => GetOverviewRequest._();
  @$core.pragma('dart2js:noInline')
  static GetOverviewRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOverviewRequest>(GetOverviewRequest.$_createMessage);
  static GetOverviewRequest? _defaultInstance;

  /// chain is the sidechain name, as the chain registry writes it.
  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);
}

class GetSignedTransactionRequest extends $pb.GeneratedMessage {
  factory GetSignedTransactionRequest({
    $core.String? chain,
    $core.String? txid,
  }) {
    final result = GetSignedTransactionRequest._();
    if (chain != null) result.chain = chain;
    if (txid != null) result.txid = txid;
    return result;
  }

  GetSignedTransactionRequest._();

  factory GetSignedTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSignedTransactionRequest()..mergeFromBuffer(data, registry);
  factory GetSignedTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSignedTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSignedTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetSignedTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignedTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignedTransactionRequest copyWith(void Function(GetSignedTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as GetSignedTransactionRequest)) as GetSignedTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSignedTransactionRequest() / GetSignedTransactionRequest.new instead')
  static GetSignedTransactionRequest create() => GetSignedTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSignedTransactionRequest._();
  @$core.override
  GetSignedTransactionRequest createEmptyInstance() => GetSignedTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSignedTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSignedTransactionRequest>(GetSignedTransactionRequest.$_createMessage);
  static GetSignedTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class GetSignedTransactionResponse extends $pb.GeneratedMessage {
  factory GetSignedTransactionResponse({
    $core.String? signedTransaction,
  }) {
    final result = GetSignedTransactionResponse._();
    if (signedTransaction != null) result.signedTransaction = signedTransaction;
    return result;
  }

  GetSignedTransactionResponse._();

  factory GetSignedTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSignedTransactionResponse()..mergeFromBuffer(data, registry);
  factory GetSignedTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSignedTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSignedTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetSignedTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'signedTransaction')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignedTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignedTransactionResponse copyWith(void Function(GetSignedTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as GetSignedTransactionResponse)) as GetSignedTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSignedTransactionResponse() / GetSignedTransactionResponse.new instead')
  static GetSignedTransactionResponse create() => GetSignedTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSignedTransactionResponse._();
  @$core.override
  GetSignedTransactionResponse createEmptyInstance() => GetSignedTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSignedTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSignedTransactionResponse>(GetSignedTransactionResponse.$_createMessage);
  static GetSignedTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signedTransaction => $_getSZ(0);
  @$pb.TagNumber(1)
  set signedTransaction($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSignedTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignedTransaction() => $_clearField(1);
}

class RebroadcastTransactionRequest extends $pb.GeneratedMessage {
  factory RebroadcastTransactionRequest({
    $core.String? chain,
    $core.String? txid,
  }) {
    final result = RebroadcastTransactionRequest._();
    if (chain != null) result.chain = chain;
    if (txid != null) result.txid = txid;
    return result;
  }

  RebroadcastTransactionRequest._();

  factory RebroadcastTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RebroadcastTransactionRequest()..mergeFromBuffer(data, registry);
  factory RebroadcastTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RebroadcastTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RebroadcastTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: RebroadcastTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RebroadcastTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RebroadcastTransactionRequest copyWith(void Function(RebroadcastTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as RebroadcastTransactionRequest)) as RebroadcastTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RebroadcastTransactionRequest() / RebroadcastTransactionRequest.new instead')
  static RebroadcastTransactionRequest create() => RebroadcastTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => RebroadcastTransactionRequest._();
  @$core.override
  RebroadcastTransactionRequest createEmptyInstance() => RebroadcastTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static RebroadcastTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RebroadcastTransactionRequest>(RebroadcastTransactionRequest.$_createMessage);
  static RebroadcastTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class RebroadcastTransactionResponse extends $pb.GeneratedMessage {
  factory RebroadcastTransactionResponse({
    $core.String? txid,
    $core.int? peerCount,
  }) {
    final result = RebroadcastTransactionResponse._();
    if (txid != null) result.txid = txid;
    if (peerCount != null) result.peerCount = peerCount;
    return result;
  }

  RebroadcastTransactionResponse._();

  factory RebroadcastTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RebroadcastTransactionResponse()..mergeFromBuffer(data, registry);
  factory RebroadcastTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RebroadcastTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RebroadcastTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: RebroadcastTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'peerCount', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RebroadcastTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RebroadcastTransactionResponse copyWith(void Function(RebroadcastTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as RebroadcastTransactionResponse)) as RebroadcastTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RebroadcastTransactionResponse() / RebroadcastTransactionResponse.new instead')
  static RebroadcastTransactionResponse create() => RebroadcastTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => RebroadcastTransactionResponse._();
  @$core.override
  RebroadcastTransactionResponse createEmptyInstance() => RebroadcastTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static RebroadcastTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RebroadcastTransactionResponse>(RebroadcastTransactionResponse.$_createMessage);
  static RebroadcastTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// peer_count counts connected peer queues that accepted the relay request.
  @$pb.TagNumber(2)
  $core.int get peerCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set peerCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerCount() => $_clearField(2);
}

class BroadcastTransactionRequest extends $pb.GeneratedMessage {
  factory BroadcastTransactionRequest({
    $core.String? chain,
    $core.String? signedTransaction,
  }) {
    final result = BroadcastTransactionRequest._();
    if (chain != null) result.chain = chain;
    if (signedTransaction != null) result.signedTransaction = signedTransaction;
    return result;
  }

  BroadcastTransactionRequest._();

  factory BroadcastTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionRequest()..mergeFromBuffer(data, registry);
  factory BroadcastTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: BroadcastTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'signedTransaction')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionRequest copyWith(void Function(BroadcastTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as BroadcastTransactionRequest)) as BroadcastTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastTransactionRequest() / BroadcastTransactionRequest.new instead')
  static BroadcastTransactionRequest create() => BroadcastTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastTransactionRequest._();
  @$core.override
  BroadcastTransactionRequest createEmptyInstance() => BroadcastTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static BroadcastTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastTransactionRequest>(BroadcastTransactionRequest.$_createMessage);
  static BroadcastTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get signedTransaction => $_getSZ(1);
  @$pb.TagNumber(2)
  set signedTransaction($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignedTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignedTransaction() => $_clearField(2);
}

class BroadcastTransactionResponse extends $pb.GeneratedMessage {
  factory BroadcastTransactionResponse({
    $core.String? txid,
    $core.int? peerCount,
  }) {
    final result = BroadcastTransactionResponse._();
    if (txid != null) result.txid = txid;
    if (peerCount != null) result.peerCount = peerCount;
    return result;
  }

  BroadcastTransactionResponse._();

  factory BroadcastTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionResponse()..mergeFromBuffer(data, registry);
  factory BroadcastTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: BroadcastTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'peerCount', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionResponse copyWith(void Function(BroadcastTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as BroadcastTransactionResponse)) as BroadcastTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastTransactionResponse() / BroadcastTransactionResponse.new instead')
  static BroadcastTransactionResponse create() => BroadcastTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastTransactionResponse._();
  @$core.override
  BroadcastTransactionResponse createEmptyInstance() => BroadcastTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static BroadcastTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastTransactionResponse>(BroadcastTransactionResponse.$_createMessage);
  static BroadcastTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// peer_count counts connected peer queues that accepted the relay request.
  @$pb.TagNumber(2)
  $core.int get peerCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set peerCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerCount() => $_clearField(2);
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
    final result = GetOverviewResponse._();
    if (blocks != null) result.blocks.addAll(blocks);
    if (recent != null) result.recent.addAll(recent);
    if (mempool != null) result.mempool = mempool;
    if (treasury != null) result.treasury = treasury;
    if (pendingBundle != null) result.pendingBundle = pendingBundle;
    if (tipHeight != null) result.tipHeight = tipHeight;
    if (source != null) result.source = source;
    return result;
  }

  GetOverviewResponse._();

  factory GetOverviewResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOverviewResponse()..mergeFromBuffer(data, registry);
  factory GetOverviewResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetOverviewResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOverviewResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetOverviewResponse.$_createMessage)
    ..pPM<Block>(1, _omitFieldNames ? '' : 'blocks', subBuilder: Block.$_createMessage)
    ..pPM<Activity>(2, _omitFieldNames ? '' : 'recent', subBuilder: Activity.$_createMessage)
    ..aOM<Mempool>(3, _omitFieldNames ? '' : 'mempool', subBuilder: Mempool.$_createMessage)
    ..aOM<Treasury>(4, _omitFieldNames ? '' : 'treasury', subBuilder: Treasury.$_createMessage)
    ..aOM<WithdrawalBundle>(5, _omitFieldNames ? '' : 'pendingBundle', subBuilder: WithdrawalBundle.$_createMessage)
    ..aI(6, _omitFieldNames ? '' : 'tipHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'source')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOverviewResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOverviewResponse copyWith(void Function(GetOverviewResponse) updates) =>
      super.copyWith((message) => updates(message as GetOverviewResponse)) as GetOverviewResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetOverviewResponse() / GetOverviewResponse.new instead')
  static GetOverviewResponse create() => GetOverviewResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetOverviewResponse._();
  @$core.override
  GetOverviewResponse createEmptyInstance() => GetOverviewResponse._();
  @$core.pragma('dart2js:noInline')
  static GetOverviewResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOverviewResponse>(GetOverviewResponse.$_createMessage);
  static GetOverviewResponse? _defaultInstance;

  /// blocks are newest first.
  @$pb.TagNumber(1)
  $pb.PbList<Block> get blocks => $_getList(0);

  /// recent is newest first, and the unconfirmed rows come before the rest.
  @$pb.TagNumber(2)
  $pb.PbList<Activity> get recent => $_getList(1);

  @$pb.TagNumber(3)
  Mempool get mempool => $_getN(2);
  @$pb.TagNumber(3)
  set mempool(Mempool value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMempool() => $_has(2);
  @$pb.TagNumber(3)
  void clearMempool() => $_clearField(3);
  @$pb.TagNumber(3)
  Mempool ensureMempool() => $_ensure(2);

  @$pb.TagNumber(4)
  Treasury get treasury => $_getN(3);
  @$pb.TagNumber(4)
  set treasury(Treasury value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTreasury() => $_has(3);
  @$pb.TagNumber(4)
  void clearTreasury() => $_clearField(4);
  @$pb.TagNumber(4)
  Treasury ensureTreasury() => $_ensure(3);

  @$pb.TagNumber(5)
  WithdrawalBundle get pendingBundle => $_getN(4);
  @$pb.TagNumber(5)
  set pendingBundle(WithdrawalBundle value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPendingBundle() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingBundle() => $_clearField(5);
  @$pb.TagNumber(5)
  WithdrawalBundle ensurePendingBundle() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get tipHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set tipHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTipHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearTipHeight() => $_clearField(6);

  /// source reads "index" or "node", so a reader knows what answered.
  @$pb.TagNumber(7)
  $core.String get source => $_getSZ(6);
  @$pb.TagNumber(7)
  set source($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSource() => $_has(6);
  @$pb.TagNumber(7)
  void clearSource() => $_clearField(7);
}

class ListBlocksRequest extends $pb.GeneratedMessage {
  factory ListBlocksRequest({
    $core.String? chain,
    $core.int? beforeHeight,
    $core.int? limit,
  }) {
    final result = ListBlocksRequest._();
    if (chain != null) result.chain = chain;
    if (beforeHeight != null) result.beforeHeight = beforeHeight;
    if (limit != null) result.limit = limit;
    return result;
  }

  ListBlocksRequest._();

  factory ListBlocksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksRequest()..mergeFromBuffer(data, registry);
  factory ListBlocksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: ListBlocksRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aI(2, _omitFieldNames ? '' : 'beforeHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksRequest copyWith(void Function(ListBlocksRequest) updates) =>
      super.copyWith((message) => updates(message as ListBlocksRequest)) as ListBlocksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlocksRequest() / ListBlocksRequest.new instead')
  static ListBlocksRequest create() => ListBlocksRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBlocksRequest._();
  @$core.override
  ListBlocksRequest createEmptyInstance() => ListBlocksRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksRequest>(ListBlocksRequest.$_createMessage);
  static ListBlocksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  /// before_height starts the page at this height and reads down. Leave it
  /// empty to start at the tip.
  @$pb.TagNumber(2)
  $core.int get beforeHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set beforeHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBeforeHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeforeHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class ListBlocksResponse extends $pb.GeneratedMessage {
  factory ListBlocksResponse({
    $core.Iterable<Block>? blocks,
  }) {
    final result = ListBlocksResponse._();
    if (blocks != null) result.blocks.addAll(blocks);
    return result;
  }

  ListBlocksResponse._();

  factory ListBlocksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksResponse()..mergeFromBuffer(data, registry);
  factory ListBlocksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: ListBlocksResponse.$_createMessage)
    ..pPM<Block>(1, _omitFieldNames ? '' : 'blocks', subBuilder: Block.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksResponse copyWith(void Function(ListBlocksResponse) updates) =>
      super.copyWith((message) => updates(message as ListBlocksResponse)) as ListBlocksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlocksResponse() / ListBlocksResponse.new instead')
  static ListBlocksResponse create() => ListBlocksResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBlocksResponse._();
  @$core.override
  ListBlocksResponse createEmptyInstance() => ListBlocksResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksResponse>(ListBlocksResponse.$_createMessage);
  static ListBlocksResponse? _defaultInstance;

  /// blocks are newest first. A page shorter than the limit is the last one.
  @$pb.TagNumber(1)
  $pb.PbList<Block> get blocks => $_getList(0);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? chain,
    $core.String? hash,
    $core.int? height,
  }) {
    final result = GetBlockRequest._();
    if (chain != null) result.chain = chain;
    if (hash != null) result.hash = hash;
    if (height != null) result.height = height;
    return result;
  }

  GetBlockRequest._();

  factory GetBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromBuffer(data, registry);
  factory GetBlockRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aI(3, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
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
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  /// Name one of these. A hash wins when both arrive.
  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    Block? block,
    $core.Iterable<Activity>? activity,
  }) {
    final result = GetBlockResponse._();
    if (block != null) result.block = block;
    if (activity != null) result.activity.addAll(activity);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetBlockResponse.$_createMessage)
    ..aOM<Block>(1, _omitFieldNames ? '' : 'block', subBuilder: Block.$_createMessage)
    ..pPM<Activity>(2, _omitFieldNames ? '' : 'activity', subBuilder: Activity.$_createMessage)
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
  Block get block => $_getN(0);
  @$pb.TagNumber(1)
  set block(Block value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlock() => $_clearField(1);
  @$pb.TagNumber(1)
  Block ensureBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Activity> get activity => $_getList(1);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? chain,
    $core.String? txid,
  }) {
    final result = GetTransactionRequest._();
    if (chain != null) result.chain = chain;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
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
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    Transaction? transaction,
  }) {
    final result = GetTransactionResponse._();
    if (transaction != null) result.transaction = transaction;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetTransactionResponse.$_createMessage)
    ..aOM<Transaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: Transaction.$_createMessage)
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
  Transaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(Transaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  Transaction ensureTransaction() => $_ensure(0);
}

class GetAddressRequest extends $pb.GeneratedMessage {
  factory GetAddressRequest({
    $core.String? chain,
    $core.String? address,
  }) {
    final result = GetAddressRequest._();
    if (chain != null) result.chain = chain;
    if (address != null) result.address = address;
    return result;
  }

  GetAddressRequest._();

  factory GetAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressRequest()..mergeFromBuffer(data, registry);
  factory GetAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressRequest copyWith(void Function(GetAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetAddressRequest)) as GetAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressRequest() / GetAddressRequest.new instead')
  static GetAddressRequest create() => GetAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressRequest._();
  @$core.override
  GetAddressRequest createEmptyInstance() => GetAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAddressRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressRequest>(GetAddressRequest.$_createMessage);
  static GetAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);
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
    final result = GetAddressResponse._();
    if (address != null) result.address = address;
    if (confirmedBalanceSats != null) result.confirmedBalanceSats = confirmedBalanceSats;
    if (unconfirmedBalanceSats != null) result.unconfirmedBalanceSats = unconfirmedBalanceSats;
    if (totalReceivedSats != null) result.totalReceivedSats = totalReceivedSats;
    if (confirmedCoinCount != null) result.confirmedCoinCount = confirmedCoinCount;
    if (unconfirmedCoinCount != null) result.unconfirmedCoinCount = unconfirmedCoinCount;
    if (txCount != null) result.txCount = txCount;
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  GetAddressResponse._();

  factory GetAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressResponse()..mergeFromBuffer(data, registry);
  factory GetAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'confirmedBalanceSats')
    ..aInt64(3, _omitFieldNames ? '' : 'unconfirmedBalanceSats')
    ..aInt64(4, _omitFieldNames ? '' : 'totalReceivedSats')
    ..aI(5, _omitFieldNames ? '' : 'confirmedCoinCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'unconfirmedCoinCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'txCount', fieldType: $pb.PbFieldType.OU3)
    ..pPM<Transaction>(8, _omitFieldNames ? '' : 'transactions', subBuilder: Transaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressResponse copyWith(void Function(GetAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetAddressResponse)) as GetAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressResponse() / GetAddressResponse.new instead')
  static GetAddressResponse create() => GetAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressResponse._();
  @$core.override
  GetAddressResponse createEmptyInstance() => GetAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAddressResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressResponse>(GetAddressResponse.$_createMessage);
  static GetAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get confirmedBalanceSats => $_getI64(1);
  @$pb.TagNumber(2)
  set confirmedBalanceSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfirmedBalanceSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmedBalanceSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get unconfirmedBalanceSats => $_getI64(2);
  @$pb.TagNumber(3)
  set unconfirmedBalanceSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnconfirmedBalanceSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnconfirmedBalanceSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalReceivedSats => $_getI64(3);
  @$pb.TagNumber(4)
  set totalReceivedSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalReceivedSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalReceivedSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmedCoinCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmedCoinCount($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmedCoinCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedCoinCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get unconfirmedCoinCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set unconfirmedCoinCount($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUnconfirmedCoinCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnconfirmedCoinCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get txCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set txCount($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTxCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxCount() => $_clearField(7);

  /// transactions are newest first, unconfirmed first.
  @$pb.TagNumber(8)
  $pb.PbList<Transaction> get transactions => $_getList(7);
}

/// Withdrawal is one payout inside a bundle.
class Withdrawal extends $pb.GeneratedMessage {
  factory Withdrawal({
    $core.String? mainAddress,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? mainFeeSats,
    $core.int? cumulativeWeight,
  }) {
    final result = Withdrawal._();
    if (mainAddress != null) result.mainAddress = mainAddress;
    if (valueSats != null) result.valueSats = valueSats;
    if (mainFeeSats != null) result.mainFeeSats = mainFeeSats;
    if (cumulativeWeight != null) result.cumulativeWeight = cumulativeWeight;
    return result;
  }

  Withdrawal._();

  factory Withdrawal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Withdrawal()..mergeFromBuffer(data, registry);
  factory Withdrawal.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Withdrawal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Withdrawal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: Withdrawal.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mainAddress')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(3, _omitFieldNames ? '' : 'mainFeeSats')
    ..aI(4, _omitFieldNames ? '' : 'cumulativeWeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Withdrawal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Withdrawal copyWith(void Function(Withdrawal) updates) =>
      super.copyWith((message) => updates(message as Withdrawal)) as Withdrawal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Withdrawal() / Withdrawal.new instead')
  static Withdrawal create() => Withdrawal._();
  static $pb.GeneratedMessage $_createMessage() => Withdrawal._();
  @$core.override
  Withdrawal createEmptyInstance() => Withdrawal._();
  @$core.pragma('dart2js:noInline')
  static Withdrawal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Withdrawal>(Withdrawal.$_createMessage);
  static Withdrawal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mainAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set mainAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMainAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get mainFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set mainFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMainFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearMainFeeSats() => $_clearField(3);

  /// cumulative_weight counts this withdrawal and every one before it in the
  /// bundle, against max_weight.
  @$pb.TagNumber(4)
  $core.int get cumulativeWeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set cumulativeWeight($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCumulativeWeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearCumulativeWeight() => $_clearField(4);
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
    final result = WithdrawalBundle._();
    if (present != null) result.present = present;
    if (m6id != null) result.m6id = m6id;
    if (heightCreated != null) result.heightCreated = heightCreated;
    if (totalValueSats != null) result.totalValueSats = totalValueSats;
    if (totalMainFeesSats != null) result.totalMainFeesSats = totalMainFeesSats;
    if (totalWeight != null) result.totalWeight = totalWeight;
    if (maxWeight != null) result.maxWeight = maxWeight;
    if (withdrawals != null) result.withdrawals.addAll(withdrawals);
    return result;
  }

  WithdrawalBundle._();

  factory WithdrawalBundle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundle()..mergeFromBuffer(data, registry);
  factory WithdrawalBundle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundle()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundle',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: WithdrawalBundle.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'present')
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..aI(3, _omitFieldNames ? '' : 'heightCreated', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(4, _omitFieldNames ? '' : 'totalValueSats')
    ..aInt64(5, _omitFieldNames ? '' : 'totalMainFeesSats')
    ..aI(6, _omitFieldNames ? '' : 'totalWeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'maxWeight', fieldType: $pb.PbFieldType.OU3)
    ..pPM<Withdrawal>(8, _omitFieldNames ? '' : 'withdrawals', subBuilder: Withdrawal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundle copyWith(void Function(WithdrawalBundle) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundle)) as WithdrawalBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundle() / WithdrawalBundle.new instead')
  static WithdrawalBundle create() => WithdrawalBundle._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundle._();
  @$core.override
  WithdrawalBundle createEmptyInstance() => WithdrawalBundle._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundle>(WithdrawalBundle.$_createMessage);
  static WithdrawalBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get present => $_getBF(0);
  @$pb.TagNumber(1)
  set present($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPresent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPresent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get heightCreated => $_getIZ(2);
  @$pb.TagNumber(3)
  set heightCreated($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeightCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeightCreated() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalValueSats => $_getI64(3);
  @$pb.TagNumber(4)
  set totalValueSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalValueSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalValueSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalMainFeesSats => $_getI64(4);
  @$pb.TagNumber(5)
  set totalMainFeesSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalMainFeesSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalMainFeesSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalWeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalWeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalWeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalWeight() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxWeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxWeight($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxWeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxWeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<Withdrawal> get withdrawals => $_getList(7);
}

class GetWithdrawalsRequest extends $pb.GeneratedMessage {
  factory GetWithdrawalsRequest({
    $core.String? chain,
  }) {
    final result = GetWithdrawalsRequest._();
    if (chain != null) result.chain = chain;
    return result;
  }

  GetWithdrawalsRequest._();

  factory GetWithdrawalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalsRequest()..mergeFromBuffer(data, registry);
  factory GetWithdrawalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetWithdrawalsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalsRequest copyWith(void Function(GetWithdrawalsRequest) updates) =>
      super.copyWith((message) => updates(message as GetWithdrawalsRequest)) as GetWithdrawalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWithdrawalsRequest() / GetWithdrawalsRequest.new instead')
  static GetWithdrawalsRequest create() => GetWithdrawalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWithdrawalsRequest._();
  @$core.override
  GetWithdrawalsRequest createEmptyInstance() => GetWithdrawalsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWithdrawalsRequest>(GetWithdrawalsRequest.$_createMessage);
  static GetWithdrawalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);
}

class GetWithdrawalsResponse extends $pb.GeneratedMessage {
  factory GetWithdrawalsResponse({
    WithdrawalBundle? bundle,
    $core.int? lastFailedHeight,
  }) {
    final result = GetWithdrawalsResponse._();
    if (bundle != null) result.bundle = bundle;
    if (lastFailedHeight != null) result.lastFailedHeight = lastFailedHeight;
    return result;
  }

  GetWithdrawalsResponse._();

  factory GetWithdrawalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalsResponse()..mergeFromBuffer(data, registry);
  factory GetWithdrawalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'),
      createEmptyInstance: GetWithdrawalsResponse.$_createMessage)
    ..aOM<WithdrawalBundle>(1, _omitFieldNames ? '' : 'bundle', subBuilder: WithdrawalBundle.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'lastFailedHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalsResponse copyWith(void Function(GetWithdrawalsResponse) updates) =>
      super.copyWith((message) => updates(message as GetWithdrawalsResponse)) as GetWithdrawalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWithdrawalsResponse() / GetWithdrawalsResponse.new instead')
  static GetWithdrawalsResponse create() => GetWithdrawalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWithdrawalsResponse._();
  @$core.override
  GetWithdrawalsResponse createEmptyInstance() => GetWithdrawalsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWithdrawalsResponse>(GetWithdrawalsResponse.$_createMessage);
  static GetWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalBundle get bundle => $_getN(0);
  @$pb.TagNumber(1)
  set bundle(WithdrawalBundle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBundle() => $_has(0);
  @$pb.TagNumber(1)
  void clearBundle() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalBundle ensureBundle() => $_ensure(0);

  /// last_failed_height is the sidechain height of the last bundle the
  /// mainchain rejected. It is zero when none ever failed.
  @$pb.TagNumber(2)
  $core.int get lastFailedHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastFailedHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastFailedHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastFailedHeight() => $_clearField(2);
}

/// ExplorerService serves a block explorer for one sidechain.
///
/// A light client runs no node, so it reads a hosted index. A full node answers
/// from its own chain, and a node keeps no address history, so the address call
/// needs an index either way.
class ExplorerServiceApi {
  final $pb.RpcClient _client;

  ExplorerServiceApi(this._client);

  /// GetOverview answers the explorer landing page: the newest blocks, what
  /// happened last, and what the treasury holds.
  $async.Future<GetOverviewResponse> getOverview($pb.ClientContext? ctx, GetOverviewRequest request) =>
      _client.invoke<GetOverviewResponse>(ctx, 'ExplorerService', 'GetOverview', request, GetOverviewResponse());

  /// GetBlock reads one block and what it carried. The request names either a
  /// hash or a height.
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'ExplorerService', 'GetBlock', request, GetBlockResponse());

  /// ListBlocks reads a page of block headers, newest first, so a reader can
  /// walk back to the genesis block.
  $async.Future<ListBlocksResponse> listBlocks($pb.ClientContext? ctx, ListBlocksRequest request) =>
      _client.invoke<ListBlocksResponse>(ctx, 'ExplorerService', 'ListBlocks', request, ListBlocksResponse());

  /// GetTransaction reads one transaction, with the coins on both sides.
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) => _client
      .invoke<GetTransactionResponse>(ctx, 'ExplorerService', 'GetTransaction', request, GetTransactionResponse());

  /// GetSignedTransaction exports a transaction with its stored signatures.
  $async.Future<GetSignedTransactionResponse> getSignedTransaction(
          $pb.ClientContext? ctx, GetSignedTransactionRequest request) =>
      _client.invoke<GetSignedTransactionResponse>(
          ctx, 'ExplorerService', 'GetSignedTransaction', request, GetSignedTransactionResponse());

  /// RebroadcastTransaction sends a pending transaction to connected peers.
  $async.Future<RebroadcastTransactionResponse> rebroadcastTransaction(
          $pb.ClientContext? ctx, RebroadcastTransactionRequest request) =>
      _client.invoke<RebroadcastTransactionResponse>(
          ctx, 'ExplorerService', 'RebroadcastTransaction', request, RebroadcastTransactionResponse());

  /// BroadcastTransaction submits a signed transaction to the sidechain node.
  $async.Future<BroadcastTransactionResponse> broadcastTransaction(
          $pb.ClientContext? ctx, BroadcastTransactionRequest request) =>
      _client.invoke<BroadcastTransactionResponse>(
          ctx, 'ExplorerService', 'BroadcastTransaction', request, BroadcastTransactionResponse());

  /// GetAddress reads what an address holds and what it did. It needs an index,
  /// because no sidechain node keeps an address history.
  $async.Future<GetAddressResponse> getAddress($pb.ClientContext? ctx, GetAddressRequest request) =>
      _client.invoke<GetAddressResponse>(ctx, 'ExplorerService', 'GetAddress', request, GetAddressResponse());

  /// GetWithdrawals reads the bundle the chain proposes to the mainchain.
  $async.Future<GetWithdrawalsResponse> getWithdrawals($pb.ClientContext? ctx, GetWithdrawalsRequest request) => _client
      .invoke<GetWithdrawalsResponse>(ctx, 'ExplorerService', 'GetWithdrawals', request, GetWithdrawalsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
