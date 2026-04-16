//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'multisig.pbenum.dart';

export 'multisig.pbenum.dart';

class MultisigKey extends $pb.GeneratedMessage {
  factory MultisigKey({
    $core.String? owner,
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? isWallet,
    $core.Map<$core.String, $core.String>? activePsbts,
    $core.Map<$core.String, $core.String>? initialPsbts,
  }) {
    final $result = create();
    if (owner != null) {
      $result.owner = owner;
    }
    if (xpub != null) {
      $result.xpub = xpub;
    }
    if (derivationPath != null) {
      $result.derivationPath = derivationPath;
    }
    if (fingerprint != null) {
      $result.fingerprint = fingerprint;
    }
    if (originPath != null) {
      $result.originPath = originPath;
    }
    if (isWallet != null) {
      $result.isWallet = isWallet;
    }
    if (activePsbts != null) {
      $result.activePsbts.addAll(activePsbts);
    }
    if (initialPsbts != null) {
      $result.initialPsbts.addAll(initialPsbts);
    }
    return $result;
  }
  MultisigKey._() : super();
  factory MultisigKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'owner')
    ..aOS(2, _omitFieldNames ? '' : 'xpub')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'originPath')
    ..aOB(6, _omitFieldNames ? '' : 'isWallet')
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'activePsbts', entryClassName: 'MultisigKey.ActivePsbtsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('multisig.v1'))
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'initialPsbts', entryClassName: 'MultisigKey.InitialPsbtsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('multisig.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigKey clone() => MultisigKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigKey copyWith(void Function(MultisigKey) updates) => super.copyWith((message) => updates(message as MultisigKey)) as MultisigKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigKey create() => MultisigKey._();
  MultisigKey createEmptyInstance() => create();
  static $pb.PbList<MultisigKey> createRepeated() => $pb.PbList<MultisigKey>();
  @$core.pragma('dart2js:noInline')
  static MultisigKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigKey>(create);
  static MultisigKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get owner => $_getSZ(0);
  @$pb.TagNumber(1)
  set owner($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpub => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpub($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasXpub() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpub() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get originPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set originPath($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOriginPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearOriginPath() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWallet => $_getBF(5);
  @$pb.TagNumber(6)
  set isWallet($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWallet() => clearField(6);

  /// Per-transaction signed PSBTs keyed by transaction ID
  @$pb.TagNumber(7)
  $core.Map<$core.String, $core.String> get activePsbts => $_getMap(6);

  /// Per-transaction initial (unsigned) PSBTs keyed by transaction ID
  @$pb.TagNumber(8)
  $core.Map<$core.String, $core.String> get initialPsbts => $_getMap(7);
}

class AddressInfo extends $pb.GeneratedMessage {
  factory AddressInfo({
    $core.int? index,
    $core.String? address,
    $core.bool? used,
  }) {
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (address != null) {
      $result.address = address;
    }
    if (used != null) {
      $result.used = used;
    }
    return $result;
  }
  AddressInfo._() : super();
  factory AddressInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOB(3, _omitFieldNames ? '' : 'used')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressInfo clone() => AddressInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressInfo copyWith(void Function(AddressInfo) updates) => super.copyWith((message) => updates(message as AddressInfo)) as AddressInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressInfo create() => AddressInfo._();
  AddressInfo createEmptyInstance() => create();
  static $pb.PbList<AddressInfo> createRepeated() => $pb.PbList<AddressInfo>();
  @$core.pragma('dart2js:noInline')
  static AddressInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressInfo>(create);
  static AddressInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get used => $_getBF(2);
  @$pb.TagNumber(3)
  set used($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUsed() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsed() => clearField(3);
}

class UtxoDetail extends $pb.GeneratedMessage {
  factory UtxoDetail({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.double? amount,
    $core.int? confirmations,
    $core.String? scriptPubKey,
    $core.bool? spendable,
    $core.bool? solvable,
    $core.bool? safe,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (spendable != null) {
      $result.spendable = spendable;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (safe != null) {
      $result.safe = safe;
    }
    return $result;
  }
  UtxoDetail._() : super();
  factory UtxoDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOB(7, _omitFieldNames ? '' : 'spendable')
    ..aOB(8, _omitFieldNames ? '' : 'solvable')
    ..aOB(9, _omitFieldNames ? '' : 'safe')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoDetail clone() => UtxoDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoDetail copyWith(void Function(UtxoDetail) updates) => super.copyWith((message) => updates(message as UtxoDetail)) as UtxoDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoDetail create() => UtxoDetail._();
  UtxoDetail createEmptyInstance() => create();
  static $pb.PbList<UtxoDetail> createRepeated() => $pb.PbList<UtxoDetail>();
  @$core.pragma('dart2js:noInline')
  static UtxoDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoDetail>(create);
  static UtxoDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubKey($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptPubKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubKey() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get spendable => $_getBF(6);
  @$pb.TagNumber(7)
  set spendable($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSpendable() => $_has(6);
  @$pb.TagNumber(7)
  void clearSpendable() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get solvable => $_getBF(7);
  @$pb.TagNumber(8)
  set solvable($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSolvable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSolvable() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get safe => $_getBF(8);
  @$pb.TagNumber(9)
  set safe($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSafe() => $_has(8);
  @$pb.TagNumber(9)
  void clearSafe() => clearField(9);
}

class MultisigGroup extends $pb.GeneratedMessage {
  factory MultisigGroup({
    $core.String? id,
    $core.String? name,
    $core.int? n,
    $core.int? m,
    $core.Iterable<MultisigKey>? keys,
    $fixnum.Int64? created,
    $core.String? txid,
    $core.String? descriptor,
    $core.String? descriptorReceive,
    $core.String? descriptorChange,
    $core.String? watchWalletName,
    $core.Iterable<AddressInfo>? receiveAddresses,
    $core.Iterable<AddressInfo>? changeAddresses,
    $core.Iterable<UtxoDetail>? utxoDetails,
    $core.double? balance,
    $core.int? utxos,
    $core.int? nextReceiveIndex,
    $core.int? nextChangeIndex,
    $core.Iterable<$core.String>? transactionIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (n != null) {
      $result.n = n;
    }
    if (m != null) {
      $result.m = m;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (created != null) {
      $result.created = created;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (descriptor != null) {
      $result.descriptor = descriptor;
    }
    if (descriptorReceive != null) {
      $result.descriptorReceive = descriptorReceive;
    }
    if (descriptorChange != null) {
      $result.descriptorChange = descriptorChange;
    }
    if (watchWalletName != null) {
      $result.watchWalletName = watchWalletName;
    }
    if (receiveAddresses != null) {
      $result.receiveAddresses.addAll(receiveAddresses);
    }
    if (changeAddresses != null) {
      $result.changeAddresses.addAll(changeAddresses);
    }
    if (utxoDetails != null) {
      $result.utxoDetails.addAll(utxoDetails);
    }
    if (balance != null) {
      $result.balance = balance;
    }
    if (utxos != null) {
      $result.utxos = utxos;
    }
    if (nextReceiveIndex != null) {
      $result.nextReceiveIndex = nextReceiveIndex;
    }
    if (nextChangeIndex != null) {
      $result.nextChangeIndex = nextChangeIndex;
    }
    if (transactionIds != null) {
      $result.transactionIds.addAll(transactionIds);
    }
    return $result;
  }
  MultisigGroup._() : super();
  factory MultisigGroup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigGroup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigGroup', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'n', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'm', $pb.PbFieldType.O3)
    ..pc<MultisigKey>(5, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: MultisigKey.create)
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..aOS(8, _omitFieldNames ? '' : 'descriptor')
    ..aOS(9, _omitFieldNames ? '' : 'descriptorReceive')
    ..aOS(10, _omitFieldNames ? '' : 'descriptorChange')
    ..aOS(11, _omitFieldNames ? '' : 'watchWalletName')
    ..pc<AddressInfo>(12, _omitFieldNames ? '' : 'receiveAddresses', $pb.PbFieldType.PM, subBuilder: AddressInfo.create)
    ..pc<AddressInfo>(13, _omitFieldNames ? '' : 'changeAddresses', $pb.PbFieldType.PM, subBuilder: AddressInfo.create)
    ..pc<UtxoDetail>(14, _omitFieldNames ? '' : 'utxoDetails', $pb.PbFieldType.PM, subBuilder: UtxoDetail.create)
    ..a<$core.double>(15, _omitFieldNames ? '' : 'balance', $pb.PbFieldType.OD)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'utxos', $pb.PbFieldType.O3)
    ..a<$core.int>(17, _omitFieldNames ? '' : 'nextReceiveIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(18, _omitFieldNames ? '' : 'nextChangeIndex', $pb.PbFieldType.O3)
    ..pPS(19, _omitFieldNames ? '' : 'transactionIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigGroup clone() => MultisigGroup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigGroup copyWith(void Function(MultisigGroup) updates) => super.copyWith((message) => updates(message as MultisigGroup)) as MultisigGroup;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigGroup create() => MultisigGroup._();
  MultisigGroup createEmptyInstance() => create();
  static $pb.PbList<MultisigGroup> createRepeated() => $pb.PbList<MultisigGroup>();
  @$core.pragma('dart2js:noInline')
  static MultisigGroup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigGroup>(create);
  static MultisigGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get n => $_getIZ(2);
  @$pb.TagNumber(3)
  set n($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasN() => $_has(2);
  @$pb.TagNumber(3)
  void clearN() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get m => $_getIZ(3);
  @$pb.TagNumber(4)
  set m($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasM() => $_has(3);
  @$pb.TagNumber(4)
  void clearM() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<MultisigKey> get keys => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get created => $_getI64(5);
  @$pb.TagNumber(6)
  set created($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreated() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreated() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get descriptor => $_getSZ(7);
  @$pb.TagNumber(8)
  set descriptor($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDescriptor() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescriptor() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get descriptorReceive => $_getSZ(8);
  @$pb.TagNumber(9)
  set descriptorReceive($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasDescriptorReceive() => $_has(8);
  @$pb.TagNumber(9)
  void clearDescriptorReceive() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get descriptorChange => $_getSZ(9);
  @$pb.TagNumber(10)
  set descriptorChange($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDescriptorChange() => $_has(9);
  @$pb.TagNumber(10)
  void clearDescriptorChange() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get watchWalletName => $_getSZ(10);
  @$pb.TagNumber(11)
  set watchWalletName($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasWatchWalletName() => $_has(10);
  @$pb.TagNumber(11)
  void clearWatchWalletName() => clearField(11);

  @$pb.TagNumber(12)
  $core.List<AddressInfo> get receiveAddresses => $_getList(11);

  @$pb.TagNumber(13)
  $core.List<AddressInfo> get changeAddresses => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<UtxoDetail> get utxoDetails => $_getList(13);

  @$pb.TagNumber(15)
  $core.double get balance => $_getN(14);
  @$pb.TagNumber(15)
  set balance($core.double v) { $_setDouble(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasBalance() => $_has(14);
  @$pb.TagNumber(15)
  void clearBalance() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get utxos => $_getIZ(15);
  @$pb.TagNumber(16)
  set utxos($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasUtxos() => $_has(15);
  @$pb.TagNumber(16)
  void clearUtxos() => clearField(16);

  @$pb.TagNumber(17)
  $core.int get nextReceiveIndex => $_getIZ(16);
  @$pb.TagNumber(17)
  set nextReceiveIndex($core.int v) { $_setSignedInt32(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasNextReceiveIndex() => $_has(16);
  @$pb.TagNumber(17)
  void clearNextReceiveIndex() => clearField(17);

  @$pb.TagNumber(18)
  $core.int get nextChangeIndex => $_getIZ(17);
  @$pb.TagNumber(18)
  set nextChangeIndex($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasNextChangeIndex() => $_has(17);
  @$pb.TagNumber(18)
  void clearNextChangeIndex() => clearField(18);

  @$pb.TagNumber(19)
  $core.List<$core.String> get transactionIds => $_getList(18);
}

class ListGroupsResponse extends $pb.GeneratedMessage {
  factory ListGroupsResponse({
    $core.Iterable<MultisigGroup>? groups,
  }) {
    final $result = create();
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    return $result;
  }
  ListGroupsResponse._() : super();
  factory ListGroupsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<MultisigGroup>(1, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupsResponse clone() => ListGroupsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupsResponse copyWith(void Function(ListGroupsResponse) updates) => super.copyWith((message) => updates(message as ListGroupsResponse)) as ListGroupsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupsResponse create() => ListGroupsResponse._();
  ListGroupsResponse createEmptyInstance() => create();
  static $pb.PbList<ListGroupsResponse> createRepeated() => $pb.PbList<ListGroupsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListGroupsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupsResponse>(create);
  static ListGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<MultisigGroup> get groups => $_getList(0);
}

class SaveGroupRequest extends $pb.GeneratedMessage {
  factory SaveGroupRequest({
    MultisigGroup? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  SaveGroupRequest._() : super();
  factory SaveGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveGroupRequest clone() => SaveGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveGroupRequest copyWith(void Function(SaveGroupRequest) updates) => super.copyWith((message) => updates(message as SaveGroupRequest)) as SaveGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveGroupRequest create() => SaveGroupRequest._();
  SaveGroupRequest createEmptyInstance() => create();
  static $pb.PbList<SaveGroupRequest> createRepeated() => $pb.PbList<SaveGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static SaveGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveGroupRequest>(create);
  static SaveGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);
}

class SaveGroupResponse extends $pb.GeneratedMessage {
  factory SaveGroupResponse({
    MultisigGroup? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  SaveGroupResponse._() : super();
  factory SaveGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveGroupResponse clone() => SaveGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveGroupResponse copyWith(void Function(SaveGroupResponse) updates) => super.copyWith((message) => updates(message as SaveGroupResponse)) as SaveGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveGroupResponse create() => SaveGroupResponse._();
  SaveGroupResponse createEmptyInstance() => create();
  static $pb.PbList<SaveGroupResponse> createRepeated() => $pb.PbList<SaveGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static SaveGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveGroupResponse>(create);
  static SaveGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);
}

class DeleteGroupRequest extends $pb.GeneratedMessage {
  factory DeleteGroupRequest({
    $core.String? groupId,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  DeleteGroupRequest._() : super();
  factory DeleteGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteGroupRequest clone() => DeleteGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteGroupRequest copyWith(void Function(DeleteGroupRequest) updates) => super.copyWith((message) => updates(message as DeleteGroupRequest)) as DeleteGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteGroupRequest create() => DeleteGroupRequest._();
  DeleteGroupRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteGroupRequest> createRepeated() => $pb.PbList<DeleteGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteGroupRequest>(create);
  static DeleteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class KeyPSBTStatus extends $pb.GeneratedMessage {
  factory KeyPSBTStatus({
    $core.String? keyId,
    $core.String? psbt,
    $core.bool? isSigned,
    $0.Timestamp? signedAt,
  }) {
    final $result = create();
    if (keyId != null) {
      $result.keyId = keyId;
    }
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (isSigned != null) {
      $result.isSigned = isSigned;
    }
    if (signedAt != null) {
      $result.signedAt = signedAt;
    }
    return $result;
  }
  KeyPSBTStatus._() : super();
  factory KeyPSBTStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPSBTStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPSBTStatus', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'keyId')
    ..aOS(2, _omitFieldNames ? '' : 'psbt')
    ..aOB(3, _omitFieldNames ? '' : 'isSigned')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'signedAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPSBTStatus clone() => KeyPSBTStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPSBTStatus copyWith(void Function(KeyPSBTStatus) updates) => super.copyWith((message) => updates(message as KeyPSBTStatus)) as KeyPSBTStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPSBTStatus create() => KeyPSBTStatus._();
  KeyPSBTStatus createEmptyInstance() => create();
  static $pb.PbList<KeyPSBTStatus> createRepeated() => $pb.PbList<KeyPSBTStatus>();
  @$core.pragma('dart2js:noInline')
  static KeyPSBTStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPSBTStatus>(create);
  static KeyPSBTStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get psbt => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbt($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPsbt() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbt() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isSigned => $_getBF(2);
  @$pb.TagNumber(3)
  set isSigned($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsSigned() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsSigned() => clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get signedAt => $_getN(3);
  @$pb.TagNumber(4)
  set signedAt($0.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedAt() => clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureSignedAt() => $_ensure(3);
}

class MultisigTransaction extends $pb.GeneratedMessage {
  factory MultisigTransaction({
    $core.String? id,
    $core.String? groupId,
    $core.String? initialPsbt,
    $core.Iterable<KeyPSBTStatus>? keyPsbts,
    $core.String? combinedPsbt,
    $core.String? finalHex,
    $core.String? txid,
    TxStatus? status,
    TxType? type,
    $0.Timestamp? created,
    $0.Timestamp? broadcastTime,
    $core.double? amount,
    $core.String? destination,
    $core.double? fee,
    $core.Iterable<UtxoDetail>? inputs,
    $core.int? confirmations,
    $core.int? requiredSignatures,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (initialPsbt != null) {
      $result.initialPsbt = initialPsbt;
    }
    if (keyPsbts != null) {
      $result.keyPsbts.addAll(keyPsbts);
    }
    if (combinedPsbt != null) {
      $result.combinedPsbt = combinedPsbt;
    }
    if (finalHex != null) {
      $result.finalHex = finalHex;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (status != null) {
      $result.status = status;
    }
    if (type != null) {
      $result.type = type;
    }
    if (created != null) {
      $result.created = created;
    }
    if (broadcastTime != null) {
      $result.broadcastTime = broadcastTime;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (destination != null) {
      $result.destination = destination;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (requiredSignatures != null) {
      $result.requiredSignatures = requiredSignatures;
    }
    return $result;
  }
  MultisigTransaction._() : super();
  factory MultisigTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'initialPsbt')
    ..pc<KeyPSBTStatus>(4, _omitFieldNames ? '' : 'keyPsbts', $pb.PbFieldType.PM, subBuilder: KeyPSBTStatus.create)
    ..aOS(5, _omitFieldNames ? '' : 'combinedPsbt')
    ..aOS(6, _omitFieldNames ? '' : 'finalHex')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..e<TxStatus>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: TxStatus.TX_STATUS_UNSPECIFIED, valueOf: TxStatus.valueOf, enumValues: TxStatus.values)
    ..e<TxType>(9, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: TxType.TX_TYPE_UNSPECIFIED, valueOf: TxType.valueOf, enumValues: TxType.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'created', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'broadcastTime', subBuilder: $0.Timestamp.create)
    ..a<$core.double>(12, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aOS(13, _omitFieldNames ? '' : 'destination')
    ..a<$core.double>(14, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..pc<UtxoDetail>(15, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: UtxoDetail.create)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..a<$core.int>(17, _omitFieldNames ? '' : 'requiredSignatures', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigTransaction clone() => MultisigTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigTransaction copyWith(void Function(MultisigTransaction) updates) => super.copyWith((message) => updates(message as MultisigTransaction)) as MultisigTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigTransaction create() => MultisigTransaction._();
  MultisigTransaction createEmptyInstance() => create();
  static $pb.PbList<MultisigTransaction> createRepeated() => $pb.PbList<MultisigTransaction>();
  @$core.pragma('dart2js:noInline')
  static MultisigTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigTransaction>(create);
  static MultisigTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get initialPsbt => $_getSZ(2);
  @$pb.TagNumber(3)
  set initialPsbt($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInitialPsbt() => $_has(2);
  @$pb.TagNumber(3)
  void clearInitialPsbt() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<KeyPSBTStatus> get keyPsbts => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get combinedPsbt => $_getSZ(4);
  @$pb.TagNumber(5)
  set combinedPsbt($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCombinedPsbt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCombinedPsbt() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get finalHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set finalHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFinalHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearFinalHex() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => clearField(7);

  @$pb.TagNumber(8)
  TxStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(TxStatus v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(9)
  TxType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(TxType v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get created => $_getN(9);
  @$pb.TagNumber(10)
  set created($0.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreated() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreated() => clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreated() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get broadcastTime => $_getN(10);
  @$pb.TagNumber(11)
  set broadcastTime($0.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasBroadcastTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearBroadcastTime() => clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureBroadcastTime() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.double get amount => $_getN(11);
  @$pb.TagNumber(12)
  set amount($core.double v) { $_setDouble(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasAmount() => $_has(11);
  @$pb.TagNumber(12)
  void clearAmount() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get destination => $_getSZ(12);
  @$pb.TagNumber(13)
  set destination($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDestination() => $_has(12);
  @$pb.TagNumber(13)
  void clearDestination() => clearField(13);

  @$pb.TagNumber(14)
  $core.double get fee => $_getN(13);
  @$pb.TagNumber(14)
  set fee($core.double v) { $_setDouble(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasFee() => $_has(13);
  @$pb.TagNumber(14)
  void clearFee() => clearField(14);

  @$pb.TagNumber(15)
  $core.List<UtxoDetail> get inputs => $_getList(14);

  @$pb.TagNumber(16)
  $core.int get confirmations => $_getIZ(15);
  @$pb.TagNumber(16)
  set confirmations($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasConfirmations() => $_has(15);
  @$pb.TagNumber(16)
  void clearConfirmations() => clearField(16);

  @$pb.TagNumber(17)
  $core.int get requiredSignatures => $_getIZ(16);
  @$pb.TagNumber(17)
  set requiredSignatures($core.int v) { $_setSignedInt32(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasRequiredSignatures() => $_has(16);
  @$pb.TagNumber(17)
  void clearRequiredSignatures() => clearField(17);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? groupId,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  ListTransactionsRequest._() : super();
  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
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

  /// Optional: filter by group
  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<MultisigTransaction>? transactions,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<MultisigTransaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: MultisigTransaction.create)
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
  $core.List<MultisigTransaction> get transactions => $_getList(0);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? transactionId,
  }) {
    final $result = create();
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    return $result;
  }
  GetTransactionRequest._() : super();
  factory GetTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transactionId')
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
  $core.String get transactionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransactionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionId() => clearField(1);
}

class GetTransactionByTxidRequest extends $pb.GeneratedMessage {
  factory GetTransactionByTxidRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionByTxidRequest._() : super();
  factory GetTransactionByTxidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionByTxidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionByTxidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionByTxidRequest clone() => GetTransactionByTxidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionByTxidRequest copyWith(void Function(GetTransactionByTxidRequest) updates) => super.copyWith((message) => updates(message as GetTransactionByTxidRequest)) as GetTransactionByTxidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionByTxidRequest create() => GetTransactionByTxidRequest._();
  GetTransactionByTxidRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionByTxidRequest> createRepeated() => $pb.PbList<GetTransactionByTxidRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionByTxidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionByTxidRequest>(create);
  static GetTransactionByTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class SaveTransactionRequest extends $pb.GeneratedMessage {
  factory SaveTransactionRequest({
    MultisigTransaction? transaction,
  }) {
    final $result = create();
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  SaveTransactionRequest._() : super();
  factory SaveTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOM<MultisigTransaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: MultisigTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveTransactionRequest clone() => SaveTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveTransactionRequest copyWith(void Function(SaveTransactionRequest) updates) => super.copyWith((message) => updates(message as SaveTransactionRequest)) as SaveTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveTransactionRequest create() => SaveTransactionRequest._();
  SaveTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SaveTransactionRequest> createRepeated() => $pb.PbList<SaveTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SaveTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveTransactionRequest>(create);
  static SaveTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigTransaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(MultisigTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => clearField(1);
  @$pb.TagNumber(1)
  MultisigTransaction ensureTransaction() => $_ensure(0);
}

class SaveTransactionResponse extends $pb.GeneratedMessage {
  factory SaveTransactionResponse({
    MultisigTransaction? transaction,
  }) {
    final $result = create();
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  SaveTransactionResponse._() : super();
  factory SaveTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOM<MultisigTransaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: MultisigTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveTransactionResponse clone() => SaveTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveTransactionResponse copyWith(void Function(SaveTransactionResponse) updates) => super.copyWith((message) => updates(message as SaveTransactionResponse)) as SaveTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveTransactionResponse create() => SaveTransactionResponse._();
  SaveTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SaveTransactionResponse> createRepeated() => $pb.PbList<SaveTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SaveTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveTransactionResponse>(create);
  static SaveTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigTransaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(MultisigTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => clearField(1);
  @$pb.TagNumber(1)
  MultisigTransaction ensureTransaction() => $_ensure(0);
}

class SoloKey extends $pb.GeneratedMessage {
  factory SoloKey({
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.String? owner,
  }) {
    final $result = create();
    if (xpub != null) {
      $result.xpub = xpub;
    }
    if (derivationPath != null) {
      $result.derivationPath = derivationPath;
    }
    if (fingerprint != null) {
      $result.fingerprint = fingerprint;
    }
    if (originPath != null) {
      $result.originPath = originPath;
    }
    if (owner != null) {
      $result.owner = owner;
    }
    return $result;
  }
  SoloKey._() : super();
  factory SoloKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SoloKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SoloKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'originPath')
    ..aOS(5, _omitFieldNames ? '' : 'owner')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SoloKey clone() => SoloKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SoloKey copyWith(void Function(SoloKey) updates) => super.copyWith((message) => updates(message as SoloKey)) as SoloKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoloKey create() => SoloKey._();
  SoloKey createEmptyInstance() => create();
  static $pb.PbList<SoloKey> createRepeated() => $pb.PbList<SoloKey>();
  @$core.pragma('dart2js:noInline')
  static SoloKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SoloKey>(create);
  static SoloKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get originPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set originPath($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOriginPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginPath() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get owner => $_getSZ(4);
  @$pb.TagNumber(5)
  set owner($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOwner() => $_has(4);
  @$pb.TagNumber(5)
  void clearOwner() => clearField(5);
}

class ListSoloKeysResponse extends $pb.GeneratedMessage {
  factory ListSoloKeysResponse({
    $core.Iterable<SoloKey>? keys,
  }) {
    final $result = create();
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  ListSoloKeysResponse._() : super();
  factory ListSoloKeysResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSoloKeysResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSoloKeysResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<SoloKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: SoloKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSoloKeysResponse clone() => ListSoloKeysResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSoloKeysResponse copyWith(void Function(ListSoloKeysResponse) updates) => super.copyWith((message) => updates(message as ListSoloKeysResponse)) as ListSoloKeysResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSoloKeysResponse create() => ListSoloKeysResponse._();
  ListSoloKeysResponse createEmptyInstance() => create();
  static $pb.PbList<ListSoloKeysResponse> createRepeated() => $pb.PbList<ListSoloKeysResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSoloKeysResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSoloKeysResponse>(create);
  static ListSoloKeysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SoloKey> get keys => $_getList(0);
}

class AddSoloKeyRequest extends $pb.GeneratedMessage {
  factory AddSoloKeyRequest({
    SoloKey? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  AddSoloKeyRequest._() : super();
  factory AddSoloKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddSoloKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddSoloKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOM<SoloKey>(1, _omitFieldNames ? '' : 'key', subBuilder: SoloKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddSoloKeyRequest clone() => AddSoloKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddSoloKeyRequest copyWith(void Function(AddSoloKeyRequest) updates) => super.copyWith((message) => updates(message as AddSoloKeyRequest)) as AddSoloKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddSoloKeyRequest create() => AddSoloKeyRequest._();
  AddSoloKeyRequest createEmptyInstance() => create();
  static $pb.PbList<AddSoloKeyRequest> createRepeated() => $pb.PbList<AddSoloKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static AddSoloKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddSoloKeyRequest>(create);
  static AddSoloKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SoloKey get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(SoloKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
  @$pb.TagNumber(1)
  SoloKey ensureKey() => $_ensure(0);
}

class GetNextAccountIndexRequest extends $pb.GeneratedMessage {
  factory GetNextAccountIndexRequest({
    $core.Iterable<$core.int>? additionalUsedIndices,
  }) {
    final $result = create();
    if (additionalUsedIndices != null) {
      $result.additionalUsedIndices.addAll(additionalUsedIndices);
    }
    return $result;
  }
  GetNextAccountIndexRequest._() : super();
  factory GetNextAccountIndexRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNextAccountIndexRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNextAccountIndexRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'additionalUsedIndices', $pb.PbFieldType.K3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNextAccountIndexRequest clone() => GetNextAccountIndexRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNextAccountIndexRequest copyWith(void Function(GetNextAccountIndexRequest) updates) => super.copyWith((message) => updates(message as GetNextAccountIndexRequest)) as GetNextAccountIndexRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexRequest create() => GetNextAccountIndexRequest._();
  GetNextAccountIndexRequest createEmptyInstance() => create();
  static $pb.PbList<GetNextAccountIndexRequest> createRepeated() => $pb.PbList<GetNextAccountIndexRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNextAccountIndexRequest>(create);
  static GetNextAccountIndexRequest? _defaultInstance;

  /// Additional indices already claimed in the current session
  @$pb.TagNumber(1)
  $core.List<$core.int> get additionalUsedIndices => $_getList(0);
}

class GetNextAccountIndexResponse extends $pb.GeneratedMessage {
  factory GetNextAccountIndexResponse({
    $core.int? nextIndex,
  }) {
    final $result = create();
    if (nextIndex != null) {
      $result.nextIndex = nextIndex;
    }
    return $result;
  }
  GetNextAccountIndexResponse._() : super();
  factory GetNextAccountIndexResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNextAccountIndexResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNextAccountIndexResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'nextIndex', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNextAccountIndexResponse clone() => GetNextAccountIndexResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNextAccountIndexResponse copyWith(void Function(GetNextAccountIndexResponse) updates) => super.copyWith((message) => updates(message as GetNextAccountIndexResponse)) as GetNextAccountIndexResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexResponse create() => GetNextAccountIndexResponse._();
  GetNextAccountIndexResponse createEmptyInstance() => create();
  static $pb.PbList<GetNextAccountIndexResponse> createRepeated() => $pb.PbList<GetNextAccountIndexResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNextAccountIndexResponse>(create);
  static GetNextAccountIndexResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nextIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set nextIndex($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNextIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearNextIndex() => clearField(1);
}

class MultisigServiceApi {
  $pb.RpcClient _client;
  MultisigServiceApi(this._client);

  $async.Future<ListGroupsResponse> listGroups($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListGroupsResponse>(ctx, 'MultisigService', 'ListGroups', request, ListGroupsResponse())
  ;
  $async.Future<SaveGroupResponse> saveGroup($pb.ClientContext? ctx, SaveGroupRequest request) =>
    _client.invoke<SaveGroupResponse>(ctx, 'MultisigService', 'SaveGroup', request, SaveGroupResponse())
  ;
  $async.Future<$1.Empty> deleteGroup($pb.ClientContext? ctx, DeleteGroupRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'MultisigService', 'DeleteGroup', request, $1.Empty())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'MultisigService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<MultisigTransaction> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
    _client.invoke<MultisigTransaction>(ctx, 'MultisigService', 'GetTransaction', request, MultisigTransaction())
  ;
  $async.Future<MultisigTransaction> getTransactionByTxid($pb.ClientContext? ctx, GetTransactionByTxidRequest request) =>
    _client.invoke<MultisigTransaction>(ctx, 'MultisigService', 'GetTransactionByTxid', request, MultisigTransaction())
  ;
  $async.Future<SaveTransactionResponse> saveTransaction($pb.ClientContext? ctx, SaveTransactionRequest request) =>
    _client.invoke<SaveTransactionResponse>(ctx, 'MultisigService', 'SaveTransaction', request, SaveTransactionResponse())
  ;
  $async.Future<ListSoloKeysResponse> listSoloKeys($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListSoloKeysResponse>(ctx, 'MultisigService', 'ListSoloKeys', request, ListSoloKeysResponse())
  ;
  $async.Future<$1.Empty> addSoloKey($pb.ClientContext? ctx, AddSoloKeyRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'MultisigService', 'AddSoloKey', request, $1.Empty())
  ;
  $async.Future<GetNextAccountIndexResponse> getNextAccountIndex($pb.ClientContext? ctx, GetNextAccountIndexRequest request) =>
    _client.invoke<GetNextAccountIndexResponse>(ctx, 'MultisigService', 'GetNextAccountIndex', request, GetNextAccountIndexResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
