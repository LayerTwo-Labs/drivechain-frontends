// This is a generated file - do not edit.
//
// Generated from multisig/v1/multisig.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import 'multisig.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'multisig.pbenum.dart';

class MultisigKey extends $pb.GeneratedMessage {
  factory MultisigKey({
    $core.String? owner,
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? isWallet,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? activePsbts,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? initialPsbts,
  }) {
    final result = MultisigKey._();
    if (owner != null) result.owner = owner;
    if (xpub != null) result.xpub = xpub;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (isWallet != null) result.isWallet = isWallet;
    if (activePsbts != null) result.activePsbts.addEntries(activePsbts);
    if (initialPsbts != null) result.initialPsbts.addEntries(initialPsbts);
    return result;
  }

  MultisigKey._();

  factory MultisigKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigKey()..mergeFromBuffer(data, registry);
  factory MultisigKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: MultisigKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'owner')
    ..aOS(2, _omitFieldNames ? '' : 'xpub')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'originPath')
    ..aOB(6, _omitFieldNames ? '' : 'isWallet')
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'activePsbts',
        entryClassName: 'MultisigKey.ActivePsbtsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('multisig.v1'))
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'initialPsbts',
        entryClassName: 'MultisigKey.InitialPsbtsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('multisig.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigKey copyWith(void Function(MultisigKey) updates) =>
      super.copyWith((message) => updates(message as MultisigKey)) as MultisigKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigKey() / MultisigKey.new instead')
  static MultisigKey create() => MultisigKey._();
  static $pb.GeneratedMessage $_createMessage() => MultisigKey._();
  @$core.override
  MultisigKey createEmptyInstance() => MultisigKey._();
  @$core.pragma('dart2js:noInline')
  static MultisigKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigKey>(MultisigKey.$_createMessage);
  static MultisigKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get owner => $_getSZ(0);
  @$pb.TagNumber(1)
  set owner($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpub => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpub($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXpub() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpub() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get originPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set originPath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOriginPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearOriginPath() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWallet => $_getBF(5);
  @$pb.TagNumber(6)
  set isWallet($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWallet() => $_clearField(6);

  /// Per-transaction signed PSBTs keyed by transaction ID
  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.String> get activePsbts => $_getMap(6);

  /// Per-transaction initial (unsigned) PSBTs keyed by transaction ID
  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.String> get initialPsbts => $_getMap(7);
}

class AddressInfo extends $pb.GeneratedMessage {
  factory AddressInfo({
    $core.int? index,
    $core.String? address,
    $core.bool? used,
  }) {
    final result = AddressInfo._();
    if (index != null) result.index = index;
    if (address != null) result.address = address;
    if (used != null) result.used = used;
    return result;
  }

  AddressInfo._();

  factory AddressInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressInfo()..mergeFromBuffer(data, registry);
  factory AddressInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: AddressInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOB(3, _omitFieldNames ? '' : 'used')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressInfo copyWith(void Function(AddressInfo) updates) =>
      super.copyWith((message) => updates(message as AddressInfo)) as AddressInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddressInfo() / AddressInfo.new instead')
  static AddressInfo create() => AddressInfo._();
  static $pb.GeneratedMessage $_createMessage() => AddressInfo._();
  @$core.override
  AddressInfo createEmptyInstance() => AddressInfo._();
  @$core.pragma('dart2js:noInline')
  static AddressInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressInfo>(AddressInfo.$_createMessage);
  static AddressInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get used => $_getBF(2);
  @$pb.TagNumber(3)
  set used($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUsed() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsed() => $_clearField(3);
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
    final result = UtxoDetail._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (amount != null) result.amount = amount;
    if (confirmations != null) result.confirmations = confirmations;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    if (spendable != null) result.spendable = spendable;
    if (solvable != null) result.solvable = solvable;
    if (safe != null) result.safe = safe;
    return result;
  }

  UtxoDetail._();

  factory UtxoDetail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoDetail()..mergeFromBuffer(data, registry);
  factory UtxoDetail.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoDetail()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoDetail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: UtxoDetail.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aD(4, _omitFieldNames ? '' : 'amount')
    ..aI(5, _omitFieldNames ? '' : 'confirmations')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOB(7, _omitFieldNames ? '' : 'spendable')
    ..aOB(8, _omitFieldNames ? '' : 'solvable')
    ..aOB(9, _omitFieldNames ? '' : 'safe')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoDetail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoDetail copyWith(void Function(UtxoDetail) updates) =>
      super.copyWith((message) => updates(message as UtxoDetail)) as UtxoDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UtxoDetail() / UtxoDetail.new instead')
  static UtxoDetail create() => UtxoDetail._();
  static $pb.GeneratedMessage $_createMessage() => UtxoDetail._();
  @$core.override
  UtxoDetail createEmptyInstance() => UtxoDetail._();
  @$core.pragma('dart2js:noInline')
  static UtxoDetail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoDetail>(UtxoDetail.$_createMessage);
  static UtxoDetail? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptPubKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubKey() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get spendable => $_getBF(6);
  @$pb.TagNumber(7)
  set spendable($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSpendable() => $_has(6);
  @$pb.TagNumber(7)
  void clearSpendable() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get solvable => $_getBF(7);
  @$pb.TagNumber(8)
  set solvable($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSolvable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSolvable() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get safe => $_getBF(8);
  @$pb.TagNumber(9)
  set safe($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSafe() => $_has(8);
  @$pb.TagNumber(9)
  void clearSafe() => $_clearField(9);
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
    $core.String? baseDescriptor,
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
    final result = MultisigGroup._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (n != null) result.n = n;
    if (m != null) result.m = m;
    if (keys != null) result.keys.addAll(keys);
    if (created != null) result.created = created;
    if (txid != null) result.txid = txid;
    if (baseDescriptor != null) result.baseDescriptor = baseDescriptor;
    if (descriptorReceive != null) result.descriptorReceive = descriptorReceive;
    if (descriptorChange != null) result.descriptorChange = descriptorChange;
    if (watchWalletName != null) result.watchWalletName = watchWalletName;
    if (receiveAddresses != null) result.receiveAddresses.addAll(receiveAddresses);
    if (changeAddresses != null) result.changeAddresses.addAll(changeAddresses);
    if (utxoDetails != null) result.utxoDetails.addAll(utxoDetails);
    if (balance != null) result.balance = balance;
    if (utxos != null) result.utxos = utxos;
    if (nextReceiveIndex != null) result.nextReceiveIndex = nextReceiveIndex;
    if (nextChangeIndex != null) result.nextChangeIndex = nextChangeIndex;
    if (transactionIds != null) result.transactionIds.addAll(transactionIds);
    return result;
  }

  MultisigGroup._();

  factory MultisigGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigGroup()..mergeFromBuffer(data, registry);
  factory MultisigGroup.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigGroup()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: MultisigGroup.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'n')
    ..aI(4, _omitFieldNames ? '' : 'm')
    ..pPM<MultisigKey>(5, _omitFieldNames ? '' : 'keys', subBuilder: MultisigKey.$_createMessage)
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..aOS(8, _omitFieldNames ? '' : 'baseDescriptor')
    ..aOS(9, _omitFieldNames ? '' : 'descriptorReceive')
    ..aOS(10, _omitFieldNames ? '' : 'descriptorChange')
    ..aOS(11, _omitFieldNames ? '' : 'watchWalletName')
    ..pPM<AddressInfo>(12, _omitFieldNames ? '' : 'receiveAddresses', subBuilder: AddressInfo.$_createMessage)
    ..pPM<AddressInfo>(13, _omitFieldNames ? '' : 'changeAddresses', subBuilder: AddressInfo.$_createMessage)
    ..pPM<UtxoDetail>(14, _omitFieldNames ? '' : 'utxoDetails', subBuilder: UtxoDetail.$_createMessage)
    ..aD(15, _omitFieldNames ? '' : 'balance')
    ..aI(16, _omitFieldNames ? '' : 'utxos')
    ..aI(17, _omitFieldNames ? '' : 'nextReceiveIndex')
    ..aI(18, _omitFieldNames ? '' : 'nextChangeIndex')
    ..pPS(19, _omitFieldNames ? '' : 'transactionIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigGroup copyWith(void Function(MultisigGroup) updates) =>
      super.copyWith((message) => updates(message as MultisigGroup)) as MultisigGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigGroup() / MultisigGroup.new instead')
  static MultisigGroup create() => MultisigGroup._();
  static $pb.GeneratedMessage $_createMessage() => MultisigGroup._();
  @$core.override
  MultisigGroup createEmptyInstance() => MultisigGroup._();
  @$core.pragma('dart2js:noInline')
  static MultisigGroup getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigGroup>(MultisigGroup.$_createMessage);
  static MultisigGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get n => $_getIZ(2);
  @$pb.TagNumber(3)
  set n($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasN() => $_has(2);
  @$pb.TagNumber(3)
  void clearN() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get m => $_getIZ(3);
  @$pb.TagNumber(4)
  set m($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasM() => $_has(3);
  @$pb.TagNumber(4)
  void clearM() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<MultisigKey> get keys => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get created => $_getI64(5);
  @$pb.TagNumber(6)
  set created($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreated() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreated() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get baseDescriptor => $_getSZ(7);
  @$pb.TagNumber(8)
  set baseDescriptor($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBaseDescriptor() => $_has(7);
  @$pb.TagNumber(8)
  void clearBaseDescriptor() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get descriptorReceive => $_getSZ(8);
  @$pb.TagNumber(9)
  set descriptorReceive($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDescriptorReceive() => $_has(8);
  @$pb.TagNumber(9)
  void clearDescriptorReceive() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get descriptorChange => $_getSZ(9);
  @$pb.TagNumber(10)
  set descriptorChange($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDescriptorChange() => $_has(9);
  @$pb.TagNumber(10)
  void clearDescriptorChange() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get watchWalletName => $_getSZ(10);
  @$pb.TagNumber(11)
  set watchWalletName($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWatchWalletName() => $_has(10);
  @$pb.TagNumber(11)
  void clearWatchWalletName() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<AddressInfo> get receiveAddresses => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<AddressInfo> get changeAddresses => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbList<UtxoDetail> get utxoDetails => $_getList(13);

  @$pb.TagNumber(15)
  $core.double get balance => $_getN(14);
  @$pb.TagNumber(15)
  set balance($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBalance() => $_has(14);
  @$pb.TagNumber(15)
  void clearBalance() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get utxos => $_getIZ(15);
  @$pb.TagNumber(16)
  set utxos($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasUtxos() => $_has(15);
  @$pb.TagNumber(16)
  void clearUtxos() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get nextReceiveIndex => $_getIZ(16);
  @$pb.TagNumber(17)
  set nextReceiveIndex($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasNextReceiveIndex() => $_has(16);
  @$pb.TagNumber(17)
  void clearNextReceiveIndex() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get nextChangeIndex => $_getIZ(17);
  @$pb.TagNumber(18)
  set nextChangeIndex($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasNextChangeIndex() => $_has(17);
  @$pb.TagNumber(18)
  void clearNextChangeIndex() => $_clearField(18);

  @$pb.TagNumber(19)
  $pb.PbList<$core.String> get transactionIds => $_getList(18);
}

class ListGroupsResponse extends $pb.GeneratedMessage {
  factory ListGroupsResponse({
    $core.Iterable<MultisigGroup>? groups,
  }) {
    final result = ListGroupsResponse._();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  ListGroupsResponse._();

  factory ListGroupsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupsResponse()..mergeFromBuffer(data, registry);
  factory ListGroupsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: ListGroupsResponse.$_createMessage)
    ..pPM<MultisigGroup>(1, _omitFieldNames ? '' : 'groups', subBuilder: MultisigGroup.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupsResponse copyWith(void Function(ListGroupsResponse) updates) =>
      super.copyWith((message) => updates(message as ListGroupsResponse)) as ListGroupsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListGroupsResponse() / ListGroupsResponse.new instead')
  static ListGroupsResponse create() => ListGroupsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListGroupsResponse._();
  @$core.override
  ListGroupsResponse createEmptyInstance() => ListGroupsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListGroupsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupsResponse>(ListGroupsResponse.$_createMessage);
  static ListGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MultisigGroup> get groups => $_getList(0);
}

class SaveGroupRequest extends $pb.GeneratedMessage {
  factory SaveGroupRequest({
    MultisigGroup? group,
  }) {
    final result = SaveGroupRequest._();
    if (group != null) result.group = group;
    return result;
  }

  SaveGroupRequest._();

  factory SaveGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveGroupRequest()..mergeFromBuffer(data, registry);
  factory SaveGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveGroupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: SaveGroupRequest.$_createMessage)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveGroupRequest copyWith(void Function(SaveGroupRequest) updates) =>
      super.copyWith((message) => updates(message as SaveGroupRequest)) as SaveGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveGroupRequest() / SaveGroupRequest.new instead')
  static SaveGroupRequest create() => SaveGroupRequest._();
  static $pb.GeneratedMessage $_createMessage() => SaveGroupRequest._();
  @$core.override
  SaveGroupRequest createEmptyInstance() => SaveGroupRequest._();
  @$core.pragma('dart2js:noInline')
  static SaveGroupRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveGroupRequest>(SaveGroupRequest.$_createMessage);
  static SaveGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);
}

class SaveGroupResponse extends $pb.GeneratedMessage {
  factory SaveGroupResponse({
    MultisigGroup? group,
  }) {
    final result = SaveGroupResponse._();
    if (group != null) result.group = group;
    return result;
  }

  SaveGroupResponse._();

  factory SaveGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveGroupResponse()..mergeFromBuffer(data, registry);
  factory SaveGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveGroupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: SaveGroupResponse.$_createMessage)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveGroupResponse copyWith(void Function(SaveGroupResponse) updates) =>
      super.copyWith((message) => updates(message as SaveGroupResponse)) as SaveGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveGroupResponse() / SaveGroupResponse.new instead')
  static SaveGroupResponse create() => SaveGroupResponse._();
  static $pb.GeneratedMessage $_createMessage() => SaveGroupResponse._();
  @$core.override
  SaveGroupResponse createEmptyInstance() => SaveGroupResponse._();
  @$core.pragma('dart2js:noInline')
  static SaveGroupResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveGroupResponse>(SaveGroupResponse.$_createMessage);
  static SaveGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);
}

class DeleteGroupRequest extends $pb.GeneratedMessage {
  factory DeleteGroupRequest({
    $core.String? groupId,
  }) {
    final result = DeleteGroupRequest._();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  DeleteGroupRequest._();

  factory DeleteGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteGroupRequest()..mergeFromBuffer(data, registry);
  factory DeleteGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteGroupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: DeleteGroupRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteGroupRequest copyWith(void Function(DeleteGroupRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteGroupRequest)) as DeleteGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteGroupRequest() / DeleteGroupRequest.new instead')
  static DeleteGroupRequest create() => DeleteGroupRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteGroupRequest._();
  @$core.override
  DeleteGroupRequest createEmptyInstance() => DeleteGroupRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteGroupRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteGroupRequest>(DeleteGroupRequest.$_createMessage);
  static DeleteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class KeyPSBTStatus extends $pb.GeneratedMessage {
  factory KeyPSBTStatus({
    $core.String? keyId,
    $core.String? psbt,
    $core.bool? isSigned,
    $0.Timestamp? signedAt,
  }) {
    final result = KeyPSBTStatus._();
    if (keyId != null) result.keyId = keyId;
    if (psbt != null) result.psbt = psbt;
    if (isSigned != null) result.isSigned = isSigned;
    if (signedAt != null) result.signedAt = signedAt;
    return result;
  }

  KeyPSBTStatus._();

  factory KeyPSBTStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPSBTStatus()..mergeFromBuffer(data, registry);
  factory KeyPSBTStatus.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPSBTStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPSBTStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: KeyPSBTStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'keyId')
    ..aOS(2, _omitFieldNames ? '' : 'psbt')
    ..aOB(3, _omitFieldNames ? '' : 'isSigned')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'signedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPSBTStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPSBTStatus copyWith(void Function(KeyPSBTStatus) updates) =>
      super.copyWith((message) => updates(message as KeyPSBTStatus)) as KeyPSBTStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use KeyPSBTStatus() / KeyPSBTStatus.new instead')
  static KeyPSBTStatus create() => KeyPSBTStatus._();
  static $pb.GeneratedMessage $_createMessage() => KeyPSBTStatus._();
  @$core.override
  KeyPSBTStatus createEmptyInstance() => KeyPSBTStatus._();
  @$core.pragma('dart2js:noInline')
  static KeyPSBTStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPSBTStatus>(KeyPSBTStatus.$_createMessage);
  static KeyPSBTStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get psbt => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbt($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPsbt() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isSigned => $_getBF(2);
  @$pb.TagNumber(3)
  set isSigned($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsSigned() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsSigned() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get signedAt => $_getN(3);
  @$pb.TagNumber(4)
  set signedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSignedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedAt() => $_clearField(4);
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
    final result = MultisigTransaction._();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (initialPsbt != null) result.initialPsbt = initialPsbt;
    if (keyPsbts != null) result.keyPsbts.addAll(keyPsbts);
    if (combinedPsbt != null) result.combinedPsbt = combinedPsbt;
    if (finalHex != null) result.finalHex = finalHex;
    if (txid != null) result.txid = txid;
    if (status != null) result.status = status;
    if (type != null) result.type = type;
    if (created != null) result.created = created;
    if (broadcastTime != null) result.broadcastTime = broadcastTime;
    if (amount != null) result.amount = amount;
    if (destination != null) result.destination = destination;
    if (fee != null) result.fee = fee;
    if (inputs != null) result.inputs.addAll(inputs);
    if (confirmations != null) result.confirmations = confirmations;
    if (requiredSignatures != null) result.requiredSignatures = requiredSignatures;
    return result;
  }

  MultisigTransaction._();

  factory MultisigTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigTransaction()..mergeFromBuffer(data, registry);
  factory MultisigTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: MultisigTransaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'initialPsbt')
    ..pPM<KeyPSBTStatus>(4, _omitFieldNames ? '' : 'keyPsbts', subBuilder: KeyPSBTStatus.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'combinedPsbt')
    ..aOS(6, _omitFieldNames ? '' : 'finalHex')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..aE<TxStatus>(8, _omitFieldNames ? '' : 'status', enumValues: TxStatus.values)
    ..aE<TxType>(9, _omitFieldNames ? '' : 'type', enumValues: TxType.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'created', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'broadcastTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aD(12, _omitFieldNames ? '' : 'amount')
    ..aOS(13, _omitFieldNames ? '' : 'destination')
    ..aD(14, _omitFieldNames ? '' : 'fee')
    ..pPM<UtxoDetail>(15, _omitFieldNames ? '' : 'inputs', subBuilder: UtxoDetail.$_createMessage)
    ..aI(16, _omitFieldNames ? '' : 'confirmations')
    ..aI(17, _omitFieldNames ? '' : 'requiredSignatures')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigTransaction copyWith(void Function(MultisigTransaction) updates) =>
      super.copyWith((message) => updates(message as MultisigTransaction)) as MultisigTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigTransaction() / MultisigTransaction.new instead')
  static MultisigTransaction create() => MultisigTransaction._();
  static $pb.GeneratedMessage $_createMessage() => MultisigTransaction._();
  @$core.override
  MultisigTransaction createEmptyInstance() => MultisigTransaction._();
  @$core.pragma('dart2js:noInline')
  static MultisigTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigTransaction>(MultisigTransaction.$_createMessage);
  static MultisigTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get initialPsbt => $_getSZ(2);
  @$pb.TagNumber(3)
  set initialPsbt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInitialPsbt() => $_has(2);
  @$pb.TagNumber(3)
  void clearInitialPsbt() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<KeyPSBTStatus> get keyPsbts => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get combinedPsbt => $_getSZ(4);
  @$pb.TagNumber(5)
  set combinedPsbt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCombinedPsbt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCombinedPsbt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get finalHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set finalHex($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFinalHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearFinalHex() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => $_clearField(7);

  @$pb.TagNumber(8)
  TxStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(TxStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  TxType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(TxType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get created => $_getN(9);
  @$pb.TagNumber(10)
  set created($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreated() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreated() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreated() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get broadcastTime => $_getN(10);
  @$pb.TagNumber(11)
  set broadcastTime($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasBroadcastTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearBroadcastTime() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureBroadcastTime() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.double get amount => $_getN(11);
  @$pb.TagNumber(12)
  set amount($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAmount() => $_has(11);
  @$pb.TagNumber(12)
  void clearAmount() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get destination => $_getSZ(12);
  @$pb.TagNumber(13)
  set destination($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDestination() => $_has(12);
  @$pb.TagNumber(13)
  void clearDestination() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get fee => $_getN(13);
  @$pb.TagNumber(14)
  set fee($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasFee() => $_has(13);
  @$pb.TagNumber(14)
  void clearFee() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<UtxoDetail> get inputs => $_getList(14);

  @$pb.TagNumber(16)
  $core.int get confirmations => $_getIZ(15);
  @$pb.TagNumber(16)
  set confirmations($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasConfirmations() => $_has(15);
  @$pb.TagNumber(16)
  void clearConfirmations() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get requiredSignatures => $_getIZ(16);
  @$pb.TagNumber(17)
  set requiredSignatures($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasRequiredSignatures() => $_has(16);
  @$pb.TagNumber(17)
  void clearRequiredSignatures() => $_clearField(17);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? groupId,
  }) {
    final result = ListTransactionsRequest._();
    if (groupId != null) result.groupId = groupId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
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

  /// Optional: filter by group
  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<MultisigTransaction>? transactions,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<MultisigTransaction>(1, _omitFieldNames ? '' : 'transactions',
        subBuilder: MultisigTransaction.$_createMessage)
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
  $pb.PbList<MultisigTransaction> get transactions => $_getList(0);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? transactionId,
  }) {
    final result = GetTransactionRequest._();
    if (transactionId != null) result.transactionId = transactionId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: GetTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'transactionId')
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
  $core.String get transactionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transactionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransactionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionId() => $_clearField(1);
}

class GetTransactionByTxidRequest extends $pb.GeneratedMessage {
  factory GetTransactionByTxidRequest({
    $core.String? txid,
  }) {
    final result = GetTransactionByTxidRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionByTxidRequest._();

  factory GetTransactionByTxidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionByTxidRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionByTxidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionByTxidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionByTxidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: GetTransactionByTxidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionByTxidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionByTxidRequest copyWith(void Function(GetTransactionByTxidRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionByTxidRequest)) as GetTransactionByTxidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionByTxidRequest() / GetTransactionByTxidRequest.new instead')
  static GetTransactionByTxidRequest create() => GetTransactionByTxidRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionByTxidRequest._();
  @$core.override
  GetTransactionByTxidRequest createEmptyInstance() => GetTransactionByTxidRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionByTxidRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionByTxidRequest>(GetTransactionByTxidRequest.$_createMessage);
  static GetTransactionByTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class SaveTransactionRequest extends $pb.GeneratedMessage {
  factory SaveTransactionRequest({
    MultisigTransaction? transaction,
  }) {
    final result = SaveTransactionRequest._();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  SaveTransactionRequest._();

  factory SaveTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveTransactionRequest()..mergeFromBuffer(data, registry);
  factory SaveTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: SaveTransactionRequest.$_createMessage)
    ..aOM<MultisigTransaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: MultisigTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveTransactionRequest copyWith(void Function(SaveTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SaveTransactionRequest)) as SaveTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveTransactionRequest() / SaveTransactionRequest.new instead')
  static SaveTransactionRequest create() => SaveTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SaveTransactionRequest._();
  @$core.override
  SaveTransactionRequest createEmptyInstance() => SaveTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SaveTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveTransactionRequest>(SaveTransactionRequest.$_createMessage);
  static SaveTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigTransaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(MultisigTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  MultisigTransaction ensureTransaction() => $_ensure(0);
}

class SaveTransactionResponse extends $pb.GeneratedMessage {
  factory SaveTransactionResponse({
    MultisigTransaction? transaction,
  }) {
    final result = SaveTransactionResponse._();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  SaveTransactionResponse._();

  factory SaveTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveTransactionResponse()..mergeFromBuffer(data, registry);
  factory SaveTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: SaveTransactionResponse.$_createMessage)
    ..aOM<MultisigTransaction>(1, _omitFieldNames ? '' : 'transaction', subBuilder: MultisigTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveTransactionResponse copyWith(void Function(SaveTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SaveTransactionResponse)) as SaveTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveTransactionResponse() / SaveTransactionResponse.new instead')
  static SaveTransactionResponse create() => SaveTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SaveTransactionResponse._();
  @$core.override
  SaveTransactionResponse createEmptyInstance() => SaveTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SaveTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveTransactionResponse>(SaveTransactionResponse.$_createMessage);
  static SaveTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigTransaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(MultisigTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
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
    final result = SoloKey._();
    if (xpub != null) result.xpub = xpub;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (owner != null) result.owner = owner;
    return result;
  }

  SoloKey._();

  factory SoloKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SoloKey()..mergeFromBuffer(data, registry);
  factory SoloKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SoloKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SoloKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: SoloKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'originPath')
    ..aOS(5, _omitFieldNames ? '' : 'owner')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoloKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoloKey copyWith(void Function(SoloKey) updates) =>
      super.copyWith((message) => updates(message as SoloKey)) as SoloKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SoloKey() / SoloKey.new instead')
  static SoloKey create() => SoloKey._();
  static $pb.GeneratedMessage $_createMessage() => SoloKey._();
  @$core.override
  SoloKey createEmptyInstance() => SoloKey._();
  @$core.pragma('dart2js:noInline')
  static SoloKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SoloKey>(SoloKey.$_createMessage);
  static SoloKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get originPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set originPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOriginPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get owner => $_getSZ(4);
  @$pb.TagNumber(5)
  set owner($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOwner() => $_has(4);
  @$pb.TagNumber(5)
  void clearOwner() => $_clearField(5);
}

class ListSoloKeysResponse extends $pb.GeneratedMessage {
  factory ListSoloKeysResponse({
    $core.Iterable<SoloKey>? keys,
  }) {
    final result = ListSoloKeysResponse._();
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  ListSoloKeysResponse._();

  factory ListSoloKeysResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSoloKeysResponse()..mergeFromBuffer(data, registry);
  factory ListSoloKeysResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSoloKeysResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSoloKeysResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: ListSoloKeysResponse.$_createMessage)
    ..pPM<SoloKey>(1, _omitFieldNames ? '' : 'keys', subBuilder: SoloKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoloKeysResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoloKeysResponse copyWith(void Function(ListSoloKeysResponse) updates) =>
      super.copyWith((message) => updates(message as ListSoloKeysResponse)) as ListSoloKeysResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSoloKeysResponse() / ListSoloKeysResponse.new instead')
  static ListSoloKeysResponse create() => ListSoloKeysResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSoloKeysResponse._();
  @$core.override
  ListSoloKeysResponse createEmptyInstance() => ListSoloKeysResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSoloKeysResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSoloKeysResponse>(ListSoloKeysResponse.$_createMessage);
  static ListSoloKeysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SoloKey> get keys => $_getList(0);
}

class AddSoloKeyRequest extends $pb.GeneratedMessage {
  factory AddSoloKeyRequest({
    SoloKey? key,
  }) {
    final result = AddSoloKeyRequest._();
    if (key != null) result.key = key;
    return result;
  }

  AddSoloKeyRequest._();

  factory AddSoloKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddSoloKeyRequest()..mergeFromBuffer(data, registry);
  factory AddSoloKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddSoloKeyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddSoloKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: AddSoloKeyRequest.$_createMessage)
    ..aOM<SoloKey>(1, _omitFieldNames ? '' : 'key', subBuilder: SoloKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSoloKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSoloKeyRequest copyWith(void Function(AddSoloKeyRequest) updates) =>
      super.copyWith((message) => updates(message as AddSoloKeyRequest)) as AddSoloKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddSoloKeyRequest() / AddSoloKeyRequest.new instead')
  static AddSoloKeyRequest create() => AddSoloKeyRequest._();
  static $pb.GeneratedMessage $_createMessage() => AddSoloKeyRequest._();
  @$core.override
  AddSoloKeyRequest createEmptyInstance() => AddSoloKeyRequest._();
  @$core.pragma('dart2js:noInline')
  static AddSoloKeyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddSoloKeyRequest>(AddSoloKeyRequest.$_createMessage);
  static AddSoloKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SoloKey get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(SoloKey value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
  @$pb.TagNumber(1)
  SoloKey ensureKey() => $_ensure(0);
}

class GetNextAccountIndexRequest extends $pb.GeneratedMessage {
  factory GetNextAccountIndexRequest({
    $core.Iterable<$core.int>? additionalUsedIndices,
  }) {
    final result = GetNextAccountIndexRequest._();
    if (additionalUsedIndices != null) result.additionalUsedIndices.addAll(additionalUsedIndices);
    return result;
  }

  GetNextAccountIndexRequest._();

  factory GetNextAccountIndexRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNextAccountIndexRequest()..mergeFromBuffer(data, registry);
  factory GetNextAccountIndexRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNextAccountIndexRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNextAccountIndexRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: GetNextAccountIndexRequest.$_createMessage)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'additionalUsedIndices', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNextAccountIndexRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNextAccountIndexRequest copyWith(void Function(GetNextAccountIndexRequest) updates) =>
      super.copyWith((message) => updates(message as GetNextAccountIndexRequest)) as GetNextAccountIndexRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNextAccountIndexRequest() / GetNextAccountIndexRequest.new instead')
  static GetNextAccountIndexRequest create() => GetNextAccountIndexRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNextAccountIndexRequest._();
  @$core.override
  GetNextAccountIndexRequest createEmptyInstance() => GetNextAccountIndexRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNextAccountIndexRequest>(GetNextAccountIndexRequest.$_createMessage);
  static GetNextAccountIndexRequest? _defaultInstance;

  /// Additional indices already claimed in the current session
  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get additionalUsedIndices => $_getList(0);
}

class GetNextAccountIndexResponse extends $pb.GeneratedMessage {
  factory GetNextAccountIndexResponse({
    $core.int? nextIndex,
  }) {
    final result = GetNextAccountIndexResponse._();
    if (nextIndex != null) result.nextIndex = nextIndex;
    return result;
  }

  GetNextAccountIndexResponse._();

  factory GetNextAccountIndexResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNextAccountIndexResponse()..mergeFromBuffer(data, registry);
  factory GetNextAccountIndexResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNextAccountIndexResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNextAccountIndexResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'),
      createEmptyInstance: GetNextAccountIndexResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nextIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNextAccountIndexResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNextAccountIndexResponse copyWith(void Function(GetNextAccountIndexResponse) updates) =>
      super.copyWith((message) => updates(message as GetNextAccountIndexResponse)) as GetNextAccountIndexResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNextAccountIndexResponse() / GetNextAccountIndexResponse.new instead')
  static GetNextAccountIndexResponse create() => GetNextAccountIndexResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNextAccountIndexResponse._();
  @$core.override
  GetNextAccountIndexResponse createEmptyInstance() => GetNextAccountIndexResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNextAccountIndexResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNextAccountIndexResponse>(GetNextAccountIndexResponse.$_createMessage);
  static GetNextAccountIndexResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nextIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set nextIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNextIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearNextIndex() => $_clearField(1);
}

class MultisigServiceApi {
  final $pb.RpcClient _client;

  MultisigServiceApi(this._client);

  /// Group CRUD
  $async.Future<ListGroupsResponse> listGroups($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListGroupsResponse>(ctx, 'MultisigService', 'ListGroups', request, ListGroupsResponse());
  $async.Future<SaveGroupResponse> saveGroup($pb.ClientContext? ctx, SaveGroupRequest request) =>
      _client.invoke<SaveGroupResponse>(ctx, 'MultisigService', 'SaveGroup', request, SaveGroupResponse());
  $async.Future<$1.Empty> deleteGroup($pb.ClientContext? ctx, DeleteGroupRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'MultisigService', 'DeleteGroup', request, $1.Empty());

  /// Transaction CRUD
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'MultisigService', 'ListTransactions', request, ListTransactionsResponse());
  $async.Future<MultisigTransaction> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
      _client.invoke<MultisigTransaction>(ctx, 'MultisigService', 'GetTransaction', request, MultisigTransaction());
  $async.Future<MultisigTransaction> getTransactionByTxid(
          $pb.ClientContext? ctx, GetTransactionByTxidRequest request) =>
      _client.invoke<MultisigTransaction>(
          ctx, 'MultisigService', 'GetTransactionByTxid', request, MultisigTransaction());
  $async.Future<SaveTransactionResponse> saveTransaction($pb.ClientContext? ctx, SaveTransactionRequest request) =>
      _client.invoke<SaveTransactionResponse>(
          ctx, 'MultisigService', 'SaveTransaction', request, SaveTransactionResponse());

  /// Solo key management
  $async.Future<ListSoloKeysResponse> listSoloKeys($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListSoloKeysResponse>(ctx, 'MultisigService', 'ListSoloKeys', request, ListSoloKeysResponse());
  $async.Future<$1.Empty> addSoloKey($pb.ClientContext? ctx, AddSoloKeyRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'MultisigService', 'AddSoloKey', request, $1.Empty());

  /// Account index
  $async.Future<GetNextAccountIndexResponse> getNextAccountIndex(
          $pb.ClientContext? ctx, GetNextAccountIndexRequest request) =>
      _client.invoke<GetNextAccountIndexResponse>(
          ctx, 'MultisigService', 'GetNextAccountIndex', request, GetNextAccountIndexResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
