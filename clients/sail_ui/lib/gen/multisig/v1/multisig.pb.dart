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

/// Address management messages
class AddMultisigAddressRequest extends $pb.GeneratedMessage {
  factory AddMultisigAddressRequest({
    $core.int? nRequired,
    $core.Iterable<$core.String>? keys,
    $core.String? label,
  }) {
    final $result = create();
    if (nRequired != null) {
      $result.nRequired = nRequired;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (label != null) {
      $result.label = label;
    }
    return $result;
  }
  AddMultisigAddressRequest._() : super();
  factory AddMultisigAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'nRequired', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest clone() => AddMultisigAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest copyWith(void Function(AddMultisigAddressRequest) updates) => super.copyWith((message) => updates(message as AddMultisigAddressRequest)) as AddMultisigAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest create() => AddMultisigAddressRequest._();
  AddMultisigAddressRequest createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressRequest> createRepeated() => $pb.PbList<AddMultisigAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressRequest>(create);
  static AddMultisigAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nRequired => $_getIZ(0);
  @$pb.TagNumber(1)
  set nRequired($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNRequired() => $_has(0);
  @$pb.TagNumber(1)
  void clearNRequired() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get keys => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);
}

class AddMultisigAddressResponse extends $pb.GeneratedMessage {
  factory AddMultisigAddressResponse({
    $core.String? address,
    $core.String? redeemScript,
    $core.String? descriptor,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (descriptor != null) {
      $result.descriptor = descriptor;
    }
    return $result;
  }
  AddMultisigAddressResponse._() : super();
  factory AddMultisigAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(3, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse clone() => AddMultisigAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse copyWith(void Function(AddMultisigAddressResponse) updates) => super.copyWith((message) => updates(message as AddMultisigAddressResponse)) as AddMultisigAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse create() => AddMultisigAddressResponse._();
  AddMultisigAddressResponse createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressResponse> createRepeated() => $pb.PbList<AddMultisigAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressResponse>(create);
  static AddMultisigAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get redeemScript => $_getSZ(1);
  @$pb.TagNumber(2)
  set redeemScript($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRedeemScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedeemScript() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get descriptor => $_getSZ(2);
  @$pb.TagNumber(3)
  set descriptor($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescriptor() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescriptor() => clearField(3);
}

class ImportAddressRequest extends $pb.GeneratedMessage {
  factory ImportAddressRequest({
    $core.String? address,
    $core.String? label,
    $core.bool? rescan,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (label != null) {
      $result.label = label;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    return $result;
  }
  ImportAddressRequest._() : super();
  factory ImportAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'rescan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressRequest clone() => ImportAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressRequest copyWith(void Function(ImportAddressRequest) updates) => super.copyWith((message) => updates(message as ImportAddressRequest)) as ImportAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest create() => ImportAddressRequest._();
  ImportAddressRequest createEmptyInstance() => create();
  static $pb.PbList<ImportAddressRequest> createRepeated() => $pb.PbList<ImportAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressRequest>(create);
  static ImportAddressRequest? _defaultInstance;

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
  $core.bool get rescan => $_getBF(2);
  @$pb.TagNumber(3)
  set rescan($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRescan() => $_has(2);
  @$pb.TagNumber(3)
  void clearRescan() => clearField(3);
}

class ImportAddressResponse extends $pb.GeneratedMessage {
  factory ImportAddressResponse() => create();
  ImportAddressResponse._() : super();
  factory ImportAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressResponse clone() => ImportAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressResponse copyWith(void Function(ImportAddressResponse) updates) => super.copyWith((message) => updates(message as ImportAddressResponse)) as ImportAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse create() => ImportAddressResponse._();
  ImportAddressResponse createEmptyInstance() => create();
  static $pb.PbList<ImportAddressResponse> createRepeated() => $pb.PbList<ImportAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressResponse>(create);
  static ImportAddressResponse? _defaultInstance;
}

class GetAddressInfoRequest extends $pb.GeneratedMessage {
  factory GetAddressInfoRequest({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetAddressInfoRequest._() : super();
  factory GetAddressInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressInfoRequest clone() => GetAddressInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressInfoRequest copyWith(void Function(GetAddressInfoRequest) updates) => super.copyWith((message) => updates(message as GetAddressInfoRequest)) as GetAddressInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressInfoRequest create() => GetAddressInfoRequest._();
  GetAddressInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetAddressInfoRequest> createRepeated() => $pb.PbList<GetAddressInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressInfoRequest>(create);
  static GetAddressInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class GetAddressInfoResponse extends $pb.GeneratedMessage {
  factory GetAddressInfoResponse({
    $core.String? address,
    $core.String? scriptPubKey,
    $core.bool? isMine,
    $core.bool? isWatchonly,
    $core.bool? solvable,
    $core.String? desc,
    $core.bool? isScript,
    $core.bool? isChange,
    $core.bool? isWitness,
    $core.int? witnessVersion,
    $core.String? witnessProgram,
    $core.String? script,
    $core.String? hex,
    $core.Iterable<$core.String>? pubkeys,
    $core.int? sigsRequired,
    $core.String? pubkey,
    $core.bool? isCompressed,
    $core.String? label,
    $fixnum.Int64? timestamp,
    $core.String? hdKeyPath,
    $core.String? hdSeedId,
    $core.String? hdFingerprint,
    $core.Iterable<$core.String>? labels,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (isMine != null) {
      $result.isMine = isMine;
    }
    if (isWatchonly != null) {
      $result.isWatchonly = isWatchonly;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (desc != null) {
      $result.desc = desc;
    }
    if (isScript != null) {
      $result.isScript = isScript;
    }
    if (isChange != null) {
      $result.isChange = isChange;
    }
    if (isWitness != null) {
      $result.isWitness = isWitness;
    }
    if (witnessVersion != null) {
      $result.witnessVersion = witnessVersion;
    }
    if (witnessProgram != null) {
      $result.witnessProgram = witnessProgram;
    }
    if (script != null) {
      $result.script = script;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (pubkeys != null) {
      $result.pubkeys.addAll(pubkeys);
    }
    if (sigsRequired != null) {
      $result.sigsRequired = sigsRequired;
    }
    if (pubkey != null) {
      $result.pubkey = pubkey;
    }
    if (isCompressed != null) {
      $result.isCompressed = isCompressed;
    }
    if (label != null) {
      $result.label = label;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (hdKeyPath != null) {
      $result.hdKeyPath = hdKeyPath;
    }
    if (hdSeedId != null) {
      $result.hdSeedId = hdSeedId;
    }
    if (hdFingerprint != null) {
      $result.hdFingerprint = hdFingerprint;
    }
    if (labels != null) {
      $result.labels.addAll(labels);
    }
    return $result;
  }
  GetAddressInfoResponse._() : super();
  factory GetAddressInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOB(3, _omitFieldNames ? '' : 'isMine')
    ..aOB(4, _omitFieldNames ? '' : 'isWatchonly')
    ..aOB(5, _omitFieldNames ? '' : 'solvable')
    ..aOS(6, _omitFieldNames ? '' : 'desc')
    ..aOB(7, _omitFieldNames ? '' : 'isScript')
    ..aOB(8, _omitFieldNames ? '' : 'isChange')
    ..aOB(9, _omitFieldNames ? '' : 'isWitness')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'witnessVersion', $pb.PbFieldType.O3)
    ..aOS(11, _omitFieldNames ? '' : 'witnessProgram')
    ..aOS(12, _omitFieldNames ? '' : 'script')
    ..aOS(13, _omitFieldNames ? '' : 'hex')
    ..pPS(14, _omitFieldNames ? '' : 'pubkeys')
    ..a<$core.int>(15, _omitFieldNames ? '' : 'sigsRequired', $pb.PbFieldType.O3)
    ..aOS(16, _omitFieldNames ? '' : 'pubkey')
    ..aOB(17, _omitFieldNames ? '' : 'isCompressed')
    ..aOS(18, _omitFieldNames ? '' : 'label')
    ..aInt64(19, _omitFieldNames ? '' : 'timestamp')
    ..aOS(20, _omitFieldNames ? '' : 'hdKeyPath')
    ..aOS(21, _omitFieldNames ? '' : 'hdSeedId')
    ..aOS(22, _omitFieldNames ? '' : 'hdFingerprint')
    ..pPS(23, _omitFieldNames ? '' : 'labels')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressInfoResponse clone() => GetAddressInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressInfoResponse copyWith(void Function(GetAddressInfoResponse) updates) => super.copyWith((message) => updates(message as GetAddressInfoResponse)) as GetAddressInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressInfoResponse create() => GetAddressInfoResponse._();
  GetAddressInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetAddressInfoResponse> createRepeated() => $pb.PbList<GetAddressInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressInfoResponse>(create);
  static GetAddressInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get scriptPubKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptPubKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isMine => $_getBF(2);
  @$pb.TagNumber(3)
  set isMine($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsMine() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsMine() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isWatchonly => $_getBF(3);
  @$pb.TagNumber(4)
  set isWatchonly($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsWatchonly() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsWatchonly() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get solvable => $_getBF(4);
  @$pb.TagNumber(5)
  set solvable($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSolvable() => $_has(4);
  @$pb.TagNumber(5)
  void clearSolvable() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get desc => $_getSZ(5);
  @$pb.TagNumber(6)
  set desc($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDesc() => $_has(5);
  @$pb.TagNumber(6)
  void clearDesc() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isScript => $_getBF(6);
  @$pb.TagNumber(7)
  set isScript($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsScript() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsScript() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isChange => $_getBF(7);
  @$pb.TagNumber(8)
  set isChange($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsChange() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsChange() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isWitness => $_getBF(8);
  @$pb.TagNumber(9)
  set isWitness($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsWitness() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsWitness() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get witnessVersion => $_getIZ(9);
  @$pb.TagNumber(10)
  set witnessVersion($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWitnessVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearWitnessVersion() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get witnessProgram => $_getSZ(10);
  @$pb.TagNumber(11)
  set witnessProgram($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasWitnessProgram() => $_has(10);
  @$pb.TagNumber(11)
  void clearWitnessProgram() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get script => $_getSZ(11);
  @$pb.TagNumber(12)
  set script($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasScript() => $_has(11);
  @$pb.TagNumber(12)
  void clearScript() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get hex => $_getSZ(12);
  @$pb.TagNumber(13)
  set hex($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasHex() => $_has(12);
  @$pb.TagNumber(13)
  void clearHex() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<$core.String> get pubkeys => $_getList(13);

  @$pb.TagNumber(15)
  $core.int get sigsRequired => $_getIZ(14);
  @$pb.TagNumber(15)
  set sigsRequired($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasSigsRequired() => $_has(14);
  @$pb.TagNumber(15)
  void clearSigsRequired() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get pubkey => $_getSZ(15);
  @$pb.TagNumber(16)
  set pubkey($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasPubkey() => $_has(15);
  @$pb.TagNumber(16)
  void clearPubkey() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get isCompressed => $_getBF(16);
  @$pb.TagNumber(17)
  set isCompressed($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasIsCompressed() => $_has(16);
  @$pb.TagNumber(17)
  void clearIsCompressed() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get label => $_getSZ(17);
  @$pb.TagNumber(18)
  set label($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasLabel() => $_has(17);
  @$pb.TagNumber(18)
  void clearLabel() => clearField(18);

  @$pb.TagNumber(19)
  $fixnum.Int64 get timestamp => $_getI64(18);
  @$pb.TagNumber(19)
  set timestamp($fixnum.Int64 v) { $_setInt64(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasTimestamp() => $_has(18);
  @$pb.TagNumber(19)
  void clearTimestamp() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get hdKeyPath => $_getSZ(19);
  @$pb.TagNumber(20)
  set hdKeyPath($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasHdKeyPath() => $_has(19);
  @$pb.TagNumber(20)
  void clearHdKeyPath() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get hdSeedId => $_getSZ(20);
  @$pb.TagNumber(21)
  set hdSeedId($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasHdSeedId() => $_has(20);
  @$pb.TagNumber(21)
  void clearHdSeedId() => clearField(21);

  @$pb.TagNumber(22)
  $core.String get hdFingerprint => $_getSZ(21);
  @$pb.TagNumber(22)
  set hdFingerprint($core.String v) { $_setString(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasHdFingerprint() => $_has(21);
  @$pb.TagNumber(22)
  void clearHdFingerprint() => clearField(22);

  @$pb.TagNumber(23)
  $core.List<$core.String> get labels => $_getList(22);
}

/// UTXO management messages
class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.int? minConf,
    $core.int? maxConf,
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (minConf != null) {
      $result.minConf = minConf;
    }
    if (maxConf != null) {
      $result.maxConf = maxConf;
    }
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  ListUnspentRequest._() : super();
  factory ListUnspentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'minConf', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'maxConf', $pb.PbFieldType.O3)
    ..pPS(3, _omitFieldNames ? '' : 'addresses')
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
  $core.int get minConf => $_getIZ(0);
  @$pb.TagNumber(1)
  set minConf($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMinConf() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinConf() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxConf => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxConf($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxConf() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxConf() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get addresses => $_getList(2);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<Utxo>? utxos,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<Utxo>(1, _omitFieldNames ? '' : 'utxos', $pb.PbFieldType.PM, subBuilder: Utxo.create)
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
  $core.List<Utxo> get utxos => $_getList(0);
}

class Utxo extends $pb.GeneratedMessage {
  factory Utxo({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.String? label,
    $core.String? scriptPubKey,
    $fixnum.Int64? amount,
    $core.int? confirmations,
    $core.String? redeemScript,
    $core.String? witnessScript,
    $core.bool? spendable,
    $core.bool? solvable,
    $core.bool? reused,
    $core.String? desc,
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
    if (label != null) {
      $result.label = label;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (spendable != null) {
      $result.spendable = spendable;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (reused != null) {
      $result.reused = reused;
    }
    if (desc != null) {
      $result.desc = desc;
    }
    if (safe != null) {
      $result.safe = safe;
    }
    return $result;
  }
  Utxo._() : super();
  factory Utxo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Utxo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Utxo', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubKey')
    ..aInt64(6, _omitFieldNames ? '' : 'amount')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aOS(8, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(9, _omitFieldNames ? '' : 'witnessScript')
    ..aOB(10, _omitFieldNames ? '' : 'spendable')
    ..aOB(11, _omitFieldNames ? '' : 'solvable')
    ..aOB(12, _omitFieldNames ? '' : 'reused')
    ..aOS(13, _omitFieldNames ? '' : 'desc')
    ..aOB(14, _omitFieldNames ? '' : 'safe')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Utxo clone() => Utxo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Utxo copyWith(void Function(Utxo) updates) => super.copyWith((message) => updates(message as Utxo)) as Utxo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Utxo create() => Utxo._();
  Utxo createEmptyInstance() => create();
  static $pb.PbList<Utxo> createRepeated() => $pb.PbList<Utxo>();
  @$core.pragma('dart2js:noInline')
  static Utxo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Utxo>(create);
  static Utxo? _defaultInstance;

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
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get scriptPubKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptPubKey($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScriptPubKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptPubKey() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amount => $_getI64(5);
  @$pb.TagNumber(6)
  set amount($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get confirmations => $_getIZ(6);
  @$pb.TagNumber(7)
  set confirmations($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasConfirmations() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfirmations() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get redeemScript => $_getSZ(7);
  @$pb.TagNumber(8)
  set redeemScript($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRedeemScript() => $_has(7);
  @$pb.TagNumber(8)
  void clearRedeemScript() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get witnessScript => $_getSZ(8);
  @$pb.TagNumber(9)
  set witnessScript($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasWitnessScript() => $_has(8);
  @$pb.TagNumber(9)
  void clearWitnessScript() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get spendable => $_getBF(9);
  @$pb.TagNumber(10)
  set spendable($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSpendable() => $_has(9);
  @$pb.TagNumber(10)
  void clearSpendable() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get solvable => $_getBF(10);
  @$pb.TagNumber(11)
  set solvable($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSolvable() => $_has(10);
  @$pb.TagNumber(11)
  void clearSolvable() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get reused => $_getBF(11);
  @$pb.TagNumber(12)
  set reused($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasReused() => $_has(11);
  @$pb.TagNumber(12)
  void clearReused() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get desc => $_getSZ(12);
  @$pb.TagNumber(13)
  set desc($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDesc() => $_has(12);
  @$pb.TagNumber(13)
  void clearDesc() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get safe => $_getBF(13);
  @$pb.TagNumber(14)
  set safe($core.bool v) { $_setBool(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasSafe() => $_has(13);
  @$pb.TagNumber(14)
  void clearSafe() => clearField(14);
}

class ListAddressGroupingsRequest extends $pb.GeneratedMessage {
  factory ListAddressGroupingsRequest() => create();
  ListAddressGroupingsRequest._() : super();
  factory ListAddressGroupingsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAddressGroupingsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAddressGroupingsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAddressGroupingsRequest clone() => ListAddressGroupingsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAddressGroupingsRequest copyWith(void Function(ListAddressGroupingsRequest) updates) => super.copyWith((message) => updates(message as ListAddressGroupingsRequest)) as ListAddressGroupingsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAddressGroupingsRequest create() => ListAddressGroupingsRequest._();
  ListAddressGroupingsRequest createEmptyInstance() => create();
  static $pb.PbList<ListAddressGroupingsRequest> createRepeated() => $pb.PbList<ListAddressGroupingsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListAddressGroupingsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAddressGroupingsRequest>(create);
  static ListAddressGroupingsRequest? _defaultInstance;
}

class ListAddressGroupingsResponse extends $pb.GeneratedMessage {
  factory ListAddressGroupingsResponse({
    $core.Iterable<AddressGrouping>? groupings,
  }) {
    final $result = create();
    if (groupings != null) {
      $result.groupings.addAll(groupings);
    }
    return $result;
  }
  ListAddressGroupingsResponse._() : super();
  factory ListAddressGroupingsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAddressGroupingsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAddressGroupingsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<AddressGrouping>(1, _omitFieldNames ? '' : 'groupings', $pb.PbFieldType.PM, subBuilder: AddressGrouping.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAddressGroupingsResponse clone() => ListAddressGroupingsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAddressGroupingsResponse copyWith(void Function(ListAddressGroupingsResponse) updates) => super.copyWith((message) => updates(message as ListAddressGroupingsResponse)) as ListAddressGroupingsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAddressGroupingsResponse create() => ListAddressGroupingsResponse._();
  ListAddressGroupingsResponse createEmptyInstance() => create();
  static $pb.PbList<ListAddressGroupingsResponse> createRepeated() => $pb.PbList<ListAddressGroupingsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAddressGroupingsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAddressGroupingsResponse>(create);
  static ListAddressGroupingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AddressGrouping> get groupings => $_getList(0);
}

class AddressGrouping extends $pb.GeneratedMessage {
  factory AddressGrouping({
    $core.Iterable<AddressInfo>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  AddressGrouping._() : super();
  factory AddressGrouping.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressGrouping.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressGrouping', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<AddressInfo>(1, _omitFieldNames ? '' : 'addresses', $pb.PbFieldType.PM, subBuilder: AddressInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressGrouping clone() => AddressGrouping()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressGrouping copyWith(void Function(AddressGrouping) updates) => super.copyWith((message) => updates(message as AddressGrouping)) as AddressGrouping;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressGrouping create() => AddressGrouping._();
  AddressGrouping createEmptyInstance() => create();
  static $pb.PbList<AddressGrouping> createRepeated() => $pb.PbList<AddressGrouping>();
  @$core.pragma('dart2js:noInline')
  static AddressGrouping getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressGrouping>(create);
  static AddressGrouping? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AddressInfo> get addresses => $_getList(0);
}

class AddressInfo extends $pb.GeneratedMessage {
  factory AddressInfo({
    $core.String? address,
    $fixnum.Int64? amount,
    $core.String? label,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (label != null) {
      $result.label = label;
    }
    return $result;
  }
  AddressInfo._() : super();
  factory AddressInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'label')
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
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);
}

/// Transaction creation messages
class CreateRawTransactionRequest extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest({
    $core.Iterable<TxInput>? inputs,
    $core.Iterable<TxOutput>? outputs,
    $core.int? locktime,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  CreateRawTransactionRequest._() : super();
  factory CreateRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<TxInput>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TxInput.create)
    ..pc<TxOutput>(2, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TxOutput.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest clone() => CreateRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest copyWith(void Function(CreateRawTransactionRequest) updates) => super.copyWith((message) => updates(message as CreateRawTransactionRequest)) as CreateRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest create() => CreateRawTransactionRequest._();
  CreateRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionRequest> createRepeated() => $pb.PbList<CreateRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest>(create);
  static CreateRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TxInput> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<TxOutput> get outputs => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);
}

class TxInput extends $pb.GeneratedMessage {
  factory TxInput({
    $core.String? txid,
    $core.int? vout,
    $core.String? sequence,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    return $result;
  }
  TxInput._() : super();
  factory TxInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TxInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'sequence')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxInput clone() => TxInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxInput copyWith(void Function(TxInput) updates) => super.copyWith((message) => updates(message as TxInput)) as TxInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TxInput create() => TxInput._();
  TxInput createEmptyInstance() => create();
  static $pb.PbList<TxInput> createRepeated() => $pb.PbList<TxInput>();
  @$core.pragma('dart2js:noInline')
  static TxInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxInput>(create);
  static TxInput? _defaultInstance;

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
  $core.String get sequence => $_getSZ(2);
  @$pb.TagNumber(3)
  set sequence($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => clearField(3);
}

class TxOutput extends $pb.GeneratedMessage {
  factory TxOutput({
    $core.String? address,
    $fixnum.Int64? amount,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  TxOutput._() : super();
  factory TxOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TxOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxOutput clone() => TxOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxOutput copyWith(void Function(TxOutput) updates) => super.copyWith((message) => updates(message as TxOutput)) as TxOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TxOutput create() => TxOutput._();
  TxOutput createEmptyInstance() => create();
  static $pb.PbList<TxOutput> createRepeated() => $pb.PbList<TxOutput>();
  @$core.pragma('dart2js:noInline')
  static TxOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxOutput>(create);
  static TxOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
}

class CreateRawTransactionResponse extends $pb.GeneratedMessage {
  factory CreateRawTransactionResponse({
    $core.String? hex,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  CreateRawTransactionResponse._() : super();
  factory CreateRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse clone() => CreateRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse copyWith(void Function(CreateRawTransactionResponse) updates) => super.copyWith((message) => updates(message as CreateRawTransactionResponse)) as CreateRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse create() => CreateRawTransactionResponse._();
  CreateRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionResponse> createRepeated() => $pb.PbList<CreateRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionResponse>(create);
  static CreateRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);
}

class CreatePsbtRequest extends $pb.GeneratedMessage {
  factory CreatePsbtRequest({
    $core.Iterable<TxInput>? inputs,
    $core.Iterable<TxOutput>? outputs,
    $core.int? locktime,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  CreatePsbtRequest._() : super();
  factory CreatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<TxInput>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TxInput.create)
    ..pc<TxOutput>(2, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TxOutput.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest clone() => CreatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest copyWith(void Function(CreatePsbtRequest) updates) => super.copyWith((message) => updates(message as CreatePsbtRequest)) as CreatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest create() => CreatePsbtRequest._();
  CreatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtRequest> createRepeated() => $pb.PbList<CreatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest>(create);
  static CreatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TxInput> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<TxOutput> get outputs => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);
}

class CreatePsbtResponse extends $pb.GeneratedMessage {
  factory CreatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CreatePsbtResponse._() : super();
  factory CreatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse clone() => CreatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse copyWith(void Function(CreatePsbtResponse) updates) => super.copyWith((message) => updates(message as CreatePsbtResponse)) as CreatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse create() => CreatePsbtResponse._();
  CreatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtResponse> createRepeated() => $pb.PbList<CreatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtResponse>(create);
  static CreatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class WalletCreateFundedPsbtRequest extends $pb.GeneratedMessage {
  factory WalletCreateFundedPsbtRequest({
    $core.Iterable<TxInput>? inputs,
    $core.Iterable<TxOutput>? outputs,
    $core.int? locktime,
    PsbtOptions? options,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (options != null) {
      $result.options = options;
    }
    return $result;
  }
  WalletCreateFundedPsbtRequest._() : super();
  factory WalletCreateFundedPsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletCreateFundedPsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletCreateFundedPsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pc<TxInput>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TxInput.create)
    ..pc<TxOutput>(2, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TxOutput.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.O3)
    ..aOM<PsbtOptions>(4, _omitFieldNames ? '' : 'options', subBuilder: PsbtOptions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletCreateFundedPsbtRequest clone() => WalletCreateFundedPsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletCreateFundedPsbtRequest copyWith(void Function(WalletCreateFundedPsbtRequest) updates) => super.copyWith((message) => updates(message as WalletCreateFundedPsbtRequest)) as WalletCreateFundedPsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletCreateFundedPsbtRequest create() => WalletCreateFundedPsbtRequest._();
  WalletCreateFundedPsbtRequest createEmptyInstance() => create();
  static $pb.PbList<WalletCreateFundedPsbtRequest> createRepeated() => $pb.PbList<WalletCreateFundedPsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static WalletCreateFundedPsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletCreateFundedPsbtRequest>(create);
  static WalletCreateFundedPsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TxInput> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<TxOutput> get outputs => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);

  @$pb.TagNumber(4)
  PsbtOptions get options => $_getN(3);
  @$pb.TagNumber(4)
  set options(PsbtOptions v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasOptions() => $_has(3);
  @$pb.TagNumber(4)
  void clearOptions() => clearField(4);
  @$pb.TagNumber(4)
  PsbtOptions ensureOptions() => $_ensure(3);
}

class PsbtOptions extends $pb.GeneratedMessage {
  factory PsbtOptions({
    $core.bool? includeWatching,
    $core.bool? changePosition,
    $core.int? changeAddress,
    $core.bool? includeUnsafe,
    $core.int? minConf,
    $core.int? maxConf,
    $core.bool? subtractFeeFromOutputs,
    $core.bool? replaceable,
    $core.int? confTarget,
    $core.String? estimateMode,
  }) {
    final $result = create();
    if (includeWatching != null) {
      $result.includeWatching = includeWatching;
    }
    if (changePosition != null) {
      $result.changePosition = changePosition;
    }
    if (changeAddress != null) {
      $result.changeAddress = changeAddress;
    }
    if (includeUnsafe != null) {
      $result.includeUnsafe = includeUnsafe;
    }
    if (minConf != null) {
      $result.minConf = minConf;
    }
    if (maxConf != null) {
      $result.maxConf = maxConf;
    }
    if (subtractFeeFromOutputs != null) {
      $result.subtractFeeFromOutputs = subtractFeeFromOutputs;
    }
    if (replaceable != null) {
      $result.replaceable = replaceable;
    }
    if (confTarget != null) {
      $result.confTarget = confTarget;
    }
    if (estimateMode != null) {
      $result.estimateMode = estimateMode;
    }
    return $result;
  }
  PsbtOptions._() : super();
  factory PsbtOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PsbtOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PsbtOptions', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'includeWatching')
    ..aOB(2, _omitFieldNames ? '' : 'changePosition')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'changeAddress', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'includeUnsafe')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'minConf', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'maxConf', $pb.PbFieldType.O3)
    ..aOB(7, _omitFieldNames ? '' : 'subtractFeeFromOutputs')
    ..aOB(8, _omitFieldNames ? '' : 'replaceable')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'confTarget', $pb.PbFieldType.O3)
    ..aOS(10, _omitFieldNames ? '' : 'estimateMode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PsbtOptions clone() => PsbtOptions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PsbtOptions copyWith(void Function(PsbtOptions) updates) => super.copyWith((message) => updates(message as PsbtOptions)) as PsbtOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PsbtOptions create() => PsbtOptions._();
  PsbtOptions createEmptyInstance() => create();
  static $pb.PbList<PsbtOptions> createRepeated() => $pb.PbList<PsbtOptions>();
  @$core.pragma('dart2js:noInline')
  static PsbtOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PsbtOptions>(create);
  static PsbtOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get includeWatching => $_getBF(0);
  @$pb.TagNumber(1)
  set includeWatching($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIncludeWatching() => $_has(0);
  @$pb.TagNumber(1)
  void clearIncludeWatching() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get changePosition => $_getBF(1);
  @$pb.TagNumber(2)
  set changePosition($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChangePosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangePosition() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get changeAddress => $_getIZ(2);
  @$pb.TagNumber(3)
  set changeAddress($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChangeAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangeAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeUnsafe => $_getBF(3);
  @$pb.TagNumber(4)
  set includeUnsafe($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIncludeUnsafe() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeUnsafe() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get minConf => $_getIZ(4);
  @$pb.TagNumber(5)
  set minConf($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMinConf() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinConf() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxConf => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxConf($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxConf() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxConf() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get subtractFeeFromOutputs => $_getBF(6);
  @$pb.TagNumber(7)
  set subtractFeeFromOutputs($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSubtractFeeFromOutputs() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubtractFeeFromOutputs() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get replaceable => $_getBF(7);
  @$pb.TagNumber(8)
  set replaceable($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasReplaceable() => $_has(7);
  @$pb.TagNumber(8)
  void clearReplaceable() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get confTarget => $_getIZ(8);
  @$pb.TagNumber(9)
  set confTarget($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasConfTarget() => $_has(8);
  @$pb.TagNumber(9)
  void clearConfTarget() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get estimateMode => $_getSZ(9);
  @$pb.TagNumber(10)
  set estimateMode($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasEstimateMode() => $_has(9);
  @$pb.TagNumber(10)
  void clearEstimateMode() => clearField(10);
}

class WalletCreateFundedPsbtResponse extends $pb.GeneratedMessage {
  factory WalletCreateFundedPsbtResponse({
    $core.String? psbt,
    $fixnum.Int64? fee,
    $core.int? changePosition,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (changePosition != null) {
      $result.changePosition = changePosition;
    }
    return $result;
  }
  WalletCreateFundedPsbtResponse._() : super();
  factory WalletCreateFundedPsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletCreateFundedPsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletCreateFundedPsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..aInt64(2, _omitFieldNames ? '' : 'fee')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'changePosition', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletCreateFundedPsbtResponse clone() => WalletCreateFundedPsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletCreateFundedPsbtResponse copyWith(void Function(WalletCreateFundedPsbtResponse) updates) => super.copyWith((message) => updates(message as WalletCreateFundedPsbtResponse)) as WalletCreateFundedPsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletCreateFundedPsbtResponse create() => WalletCreateFundedPsbtResponse._();
  WalletCreateFundedPsbtResponse createEmptyInstance() => create();
  static $pb.PbList<WalletCreateFundedPsbtResponse> createRepeated() => $pb.PbList<WalletCreateFundedPsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static WalletCreateFundedPsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletCreateFundedPsbtResponse>(create);
  static WalletCreateFundedPsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fee => $_getI64(1);
  @$pb.TagNumber(2)
  set fee($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearFee() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get changePosition => $_getIZ(2);
  @$pb.TagNumber(3)
  set changePosition($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChangePosition() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangePosition() => clearField(3);
}

/// PSBT handling messages
class DecodePsbtRequest extends $pb.GeneratedMessage {
  factory DecodePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  DecodePsbtRequest._() : super();
  factory DecodePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest clone() => DecodePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest copyWith(void Function(DecodePsbtRequest) updates) => super.copyWith((message) => updates(message as DecodePsbtRequest)) as DecodePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest create() => DecodePsbtRequest._();
  DecodePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtRequest> createRepeated() => $pb.PbList<DecodePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtRequest>(create);
  static DecodePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class DecodePsbtResponse extends $pb.GeneratedMessage {
  factory DecodePsbtResponse({
    $core.String? tx,
    $core.String? unknown,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
    $core.int? fee,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (unknown != null) {
      $result.unknown = unknown;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (fee != null) {
      $result.fee = fee;
    }
    return $result;
  }
  DecodePsbtResponse._() : super();
  factory DecodePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tx')
    ..aOS(2, _omitFieldNames ? '' : 'unknown')
    ..pc<Input>(3, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Input.create)
    ..pc<Output>(4, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Output.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse clone() => DecodePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse copyWith(void Function(DecodePsbtResponse) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse)) as DecodePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse create() => DecodePsbtResponse._();
  DecodePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse> createRepeated() => $pb.PbList<DecodePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse>(create);
  static DecodePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tx => $_getSZ(0);
  @$pb.TagNumber(1)
  set tx($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get unknown => $_getSZ(1);
  @$pb.TagNumber(2)
  set unknown($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnknown() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnknown() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<Input> get inputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<Output> get outputs => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get fee => $_getIZ(4);
  @$pb.TagNumber(5)
  set fee($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => clearField(5);
}

class Input extends $pb.GeneratedMessage {
  factory Input({
    $core.String? nonWitnessUtxo,
    $core.String? witnessUtxo,
    $core.String? partialSignatures,
    $core.String? sighash,
    $core.String? redeemScript,
    $core.String? witnessScript,
    $core.String? bip32Derivs,
    $core.String? finalScriptsig,
    $core.String? finalScriptwitness,
    $core.String? unknown,
  }) {
    final $result = create();
    if (nonWitnessUtxo != null) {
      $result.nonWitnessUtxo = nonWitnessUtxo;
    }
    if (witnessUtxo != null) {
      $result.witnessUtxo = witnessUtxo;
    }
    if (partialSignatures != null) {
      $result.partialSignatures = partialSignatures;
    }
    if (sighash != null) {
      $result.sighash = sighash;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs = bip32Derivs;
    }
    if (finalScriptsig != null) {
      $result.finalScriptsig = finalScriptsig;
    }
    if (finalScriptwitness != null) {
      $result.finalScriptwitness = finalScriptwitness;
    }
    if (unknown != null) {
      $result.unknown = unknown;
    }
    return $result;
  }
  Input._() : super();
  factory Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nonWitnessUtxo')
    ..aOS(2, _omitFieldNames ? '' : 'witnessUtxo')
    ..aOS(3, _omitFieldNames ? '' : 'partialSignatures')
    ..aOS(4, _omitFieldNames ? '' : 'sighash')
    ..aOS(5, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(6, _omitFieldNames ? '' : 'witnessScript')
    ..aOS(7, _omitFieldNames ? '' : 'bip32Derivs')
    ..aOS(8, _omitFieldNames ? '' : 'finalScriptsig')
    ..aOS(9, _omitFieldNames ? '' : 'finalScriptwitness')
    ..aOS(10, _omitFieldNames ? '' : 'unknown')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Input clone() => Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Input copyWith(void Function(Input) updates) => super.copyWith((message) => updates(message as Input)) as Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Input create() => Input._();
  Input createEmptyInstance() => create();
  static $pb.PbList<Input> createRepeated() => $pb.PbList<Input>();
  @$core.pragma('dart2js:noInline')
  static Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Input>(create);
  static Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nonWitnessUtxo => $_getSZ(0);
  @$pb.TagNumber(1)
  set nonWitnessUtxo($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNonWitnessUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearNonWitnessUtxo() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get witnessUtxo => $_getSZ(1);
  @$pb.TagNumber(2)
  set witnessUtxo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessUtxo() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessUtxo() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get partialSignatures => $_getSZ(2);
  @$pb.TagNumber(3)
  set partialSignatures($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPartialSignatures() => $_has(2);
  @$pb.TagNumber(3)
  void clearPartialSignatures() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get sighash => $_getSZ(3);
  @$pb.TagNumber(4)
  set sighash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSighash() => $_has(3);
  @$pb.TagNumber(4)
  void clearSighash() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get redeemScript => $_getSZ(4);
  @$pb.TagNumber(5)
  set redeemScript($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRedeemScript() => $_has(4);
  @$pb.TagNumber(5)
  void clearRedeemScript() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get witnessScript => $_getSZ(5);
  @$pb.TagNumber(6)
  set witnessScript($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWitnessScript() => $_has(5);
  @$pb.TagNumber(6)
  void clearWitnessScript() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get bip32Derivs => $_getSZ(6);
  @$pb.TagNumber(7)
  set bip32Derivs($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBip32Derivs() => $_has(6);
  @$pb.TagNumber(7)
  void clearBip32Derivs() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get finalScriptsig => $_getSZ(7);
  @$pb.TagNumber(8)
  set finalScriptsig($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasFinalScriptsig() => $_has(7);
  @$pb.TagNumber(8)
  void clearFinalScriptsig() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get finalScriptwitness => $_getSZ(8);
  @$pb.TagNumber(9)
  set finalScriptwitness($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFinalScriptwitness() => $_has(8);
  @$pb.TagNumber(9)
  void clearFinalScriptwitness() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get unknown => $_getSZ(9);
  @$pb.TagNumber(10)
  set unknown($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasUnknown() => $_has(9);
  @$pb.TagNumber(10)
  void clearUnknown() => clearField(10);
}

class Output extends $pb.GeneratedMessage {
  factory Output({
    $core.String? redeemScript,
    $core.String? witnessScript,
    $core.String? bip32Derivs,
    $core.String? unknown,
  }) {
    final $result = create();
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs = bip32Derivs;
    }
    if (unknown != null) {
      $result.unknown = unknown;
    }
    return $result;
  }
  Output._() : super();
  factory Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(2, _omitFieldNames ? '' : 'witnessScript')
    ..aOS(3, _omitFieldNames ? '' : 'bip32Derivs')
    ..aOS(4, _omitFieldNames ? '' : 'unknown')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Output clone() => Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Output copyWith(void Function(Output) updates) => super.copyWith((message) => updates(message as Output)) as Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Output create() => Output._();
  Output createEmptyInstance() => create();
  static $pb.PbList<Output> createRepeated() => $pb.PbList<Output>();
  @$core.pragma('dart2js:noInline')
  static Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Output>(create);
  static Output? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get redeemScript => $_getSZ(0);
  @$pb.TagNumber(1)
  set redeemScript($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRedeemScript() => $_has(0);
  @$pb.TagNumber(1)
  void clearRedeemScript() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get witnessScript => $_getSZ(1);
  @$pb.TagNumber(2)
  set witnessScript($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessScript() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get bip32Derivs => $_getSZ(2);
  @$pb.TagNumber(3)
  set bip32Derivs($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBip32Derivs() => $_has(2);
  @$pb.TagNumber(3)
  void clearBip32Derivs() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get unknown => $_getSZ(3);
  @$pb.TagNumber(4)
  set unknown($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUnknown() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnknown() => clearField(4);
}

class AnalyzePsbtRequest extends $pb.GeneratedMessage {
  factory AnalyzePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  AnalyzePsbtRequest._() : super();
  factory AnalyzePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest clone() => AnalyzePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest copyWith(void Function(AnalyzePsbtRequest) updates) => super.copyWith((message) => updates(message as AnalyzePsbtRequest)) as AnalyzePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest create() => AnalyzePsbtRequest._();
  AnalyzePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtRequest> createRepeated() => $pb.PbList<AnalyzePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtRequest>(create);
  static AnalyzePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class AnalyzePsbtResponse extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse({
    $core.Iterable<$core.String>? inputs,
    $core.String? next,
    $core.String? fee,
    $core.String? error,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (next != null) {
      $result.next = next;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  AnalyzePsbtResponse._() : super();
  factory AnalyzePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'inputs')
    ..aOS(2, _omitFieldNames ? '' : 'next')
    ..aOS(3, _omitFieldNames ? '' : 'fee')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse clone() => AnalyzePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse copyWith(void Function(AnalyzePsbtResponse) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse)) as AnalyzePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse create() => AnalyzePsbtResponse._();
  AnalyzePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse> createRepeated() => $pb.PbList<AnalyzePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse>(create);
  static AnalyzePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get next => $_getSZ(1);
  @$pb.TagNumber(2)
  set next($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNext() => $_has(1);
  @$pb.TagNumber(2)
  void clearNext() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fee => $_getSZ(2);
  @$pb.TagNumber(3)
  set fee($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearFee() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);
}

class WalletProcessPsbtRequest extends $pb.GeneratedMessage {
  factory WalletProcessPsbtRequest({
    $core.String? psbt,
    $core.bool? sign,
    $core.String? sighashType,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (sign != null) {
      $result.sign = sign;
    }
    if (sighashType != null) {
      $result.sighashType = sighashType;
    }
    return $result;
  }
  WalletProcessPsbtRequest._() : super();
  factory WalletProcessPsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletProcessPsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletProcessPsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..aOB(2, _omitFieldNames ? '' : 'sign')
    ..aOS(3, _omitFieldNames ? '' : 'sighashType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletProcessPsbtRequest clone() => WalletProcessPsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletProcessPsbtRequest copyWith(void Function(WalletProcessPsbtRequest) updates) => super.copyWith((message) => updates(message as WalletProcessPsbtRequest)) as WalletProcessPsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletProcessPsbtRequest create() => WalletProcessPsbtRequest._();
  WalletProcessPsbtRequest createEmptyInstance() => create();
  static $pb.PbList<WalletProcessPsbtRequest> createRepeated() => $pb.PbList<WalletProcessPsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static WalletProcessPsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletProcessPsbtRequest>(create);
  static WalletProcessPsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get sign => $_getBF(1);
  @$pb.TagNumber(2)
  set sign($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSign() => $_has(1);
  @$pb.TagNumber(2)
  void clearSign() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get sighashType => $_getSZ(2);
  @$pb.TagNumber(3)
  set sighashType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSighashType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSighashType() => clearField(3);
}

class WalletProcessPsbtResponse extends $pb.GeneratedMessage {
  factory WalletProcessPsbtResponse({
    $core.String? psbt,
    $core.bool? complete,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (complete != null) {
      $result.complete = complete;
    }
    return $result;
  }
  WalletProcessPsbtResponse._() : super();
  factory WalletProcessPsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletProcessPsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletProcessPsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..aOB(2, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletProcessPsbtResponse clone() => WalletProcessPsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletProcessPsbtResponse copyWith(void Function(WalletProcessPsbtResponse) updates) => super.copyWith((message) => updates(message as WalletProcessPsbtResponse)) as WalletProcessPsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletProcessPsbtResponse create() => WalletProcessPsbtResponse._();
  WalletProcessPsbtResponse createEmptyInstance() => create();
  static $pb.PbList<WalletProcessPsbtResponse> createRepeated() => $pb.PbList<WalletProcessPsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static WalletProcessPsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletProcessPsbtResponse>(create);
  static WalletProcessPsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get complete => $_getBF(1);
  @$pb.TagNumber(2)
  set complete($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasComplete() => $_has(1);
  @$pb.TagNumber(2)
  void clearComplete() => clearField(2);
}

class CombinePsbtRequest extends $pb.GeneratedMessage {
  factory CombinePsbtRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  CombinePsbtRequest._() : super();
  factory CombinePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest clone() => CombinePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest copyWith(void Function(CombinePsbtRequest) updates) => super.copyWith((message) => updates(message as CombinePsbtRequest)) as CombinePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest create() => CombinePsbtRequest._();
  CombinePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtRequest> createRepeated() => $pb.PbList<CombinePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtRequest>(create);
  static CombinePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class CombinePsbtResponse extends $pb.GeneratedMessage {
  factory CombinePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CombinePsbtResponse._() : super();
  factory CombinePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse clone() => CombinePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse copyWith(void Function(CombinePsbtResponse) updates) => super.copyWith((message) => updates(message as CombinePsbtResponse)) as CombinePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse create() => CombinePsbtResponse._();
  CombinePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtResponse> createRepeated() => $pb.PbList<CombinePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtResponse>(create);
  static CombinePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class FinalizePsbtRequest extends $pb.GeneratedMessage {
  factory FinalizePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  FinalizePsbtRequest._() : super();
  factory FinalizePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FinalizePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinalizePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FinalizePsbtRequest clone() => FinalizePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FinalizePsbtRequest copyWith(void Function(FinalizePsbtRequest) updates) => super.copyWith((message) => updates(message as FinalizePsbtRequest)) as FinalizePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinalizePsbtRequest create() => FinalizePsbtRequest._();
  FinalizePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<FinalizePsbtRequest> createRepeated() => $pb.PbList<FinalizePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static FinalizePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinalizePsbtRequest>(create);
  static FinalizePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class FinalizePsbtResponse extends $pb.GeneratedMessage {
  factory FinalizePsbtResponse({
    $core.String? psbt,
    $core.String? hex,
    $core.bool? complete,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (complete != null) {
      $result.complete = complete;
    }
    return $result;
  }
  FinalizePsbtResponse._() : super();
  factory FinalizePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FinalizePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinalizePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..aOB(3, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FinalizePsbtResponse clone() => FinalizePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FinalizePsbtResponse copyWith(void Function(FinalizePsbtResponse) updates) => super.copyWith((message) => updates(message as FinalizePsbtResponse)) as FinalizePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinalizePsbtResponse create() => FinalizePsbtResponse._();
  FinalizePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<FinalizePsbtResponse> createRepeated() => $pb.PbList<FinalizePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static FinalizePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinalizePsbtResponse>(create);
  static FinalizePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get complete => $_getBF(2);
  @$pb.TagNumber(3)
  set complete($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearComplete() => clearField(3);
}

class UtxoUpdatePsbtRequest extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  UtxoUpdatePsbtRequest._() : super();
  factory UtxoUpdatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest clone() => UtxoUpdatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest copyWith(void Function(UtxoUpdatePsbtRequest) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtRequest)) as UtxoUpdatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest create() => UtxoUpdatePsbtRequest._();
  UtxoUpdatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtRequest> createRepeated() => $pb.PbList<UtxoUpdatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtRequest>(create);
  static UtxoUpdatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class UtxoUpdatePsbtResponse extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  UtxoUpdatePsbtResponse._() : super();
  factory UtxoUpdatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse clone() => UtxoUpdatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse copyWith(void Function(UtxoUpdatePsbtResponse) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtResponse)) as UtxoUpdatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse create() => UtxoUpdatePsbtResponse._();
  UtxoUpdatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtResponse> createRepeated() => $pb.PbList<UtxoUpdatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtResponse>(create);
  static UtxoUpdatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class JoinPsbtsRequest extends $pb.GeneratedMessage {
  factory JoinPsbtsRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  JoinPsbtsRequest._() : super();
  factory JoinPsbtsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest clone() => JoinPsbtsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest copyWith(void Function(JoinPsbtsRequest) updates) => super.copyWith((message) => updates(message as JoinPsbtsRequest)) as JoinPsbtsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest create() => JoinPsbtsRequest._();
  JoinPsbtsRequest createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsRequest> createRepeated() => $pb.PbList<JoinPsbtsRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsRequest>(create);
  static JoinPsbtsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class JoinPsbtsResponse extends $pb.GeneratedMessage {
  factory JoinPsbtsResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  JoinPsbtsResponse._() : super();
  factory JoinPsbtsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse clone() => JoinPsbtsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse copyWith(void Function(JoinPsbtsResponse) updates) => super.copyWith((message) => updates(message as JoinPsbtsResponse)) as JoinPsbtsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse create() => JoinPsbtsResponse._();
  JoinPsbtsResponse createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsResponse> createRepeated() => $pb.PbList<JoinPsbtsResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsResponse>(create);
  static JoinPsbtsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

/// Transaction signing messages
class SignRawTransactionWithWalletRequest extends $pb.GeneratedMessage {
  factory SignRawTransactionWithWalletRequest({
    $core.String? hexString,
    $core.Iterable<PreviousTx>? prevTxs,
    $core.String? sighashType,
  }) {
    final $result = create();
    if (hexString != null) {
      $result.hexString = hexString;
    }
    if (prevTxs != null) {
      $result.prevTxs.addAll(prevTxs);
    }
    if (sighashType != null) {
      $result.sighashType = sighashType;
    }
    return $result;
  }
  SignRawTransactionWithWalletRequest._() : super();
  factory SignRawTransactionWithWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignRawTransactionWithWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignRawTransactionWithWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hexString')
    ..pc<PreviousTx>(2, _omitFieldNames ? '' : 'prevTxs', $pb.PbFieldType.PM, subBuilder: PreviousTx.create)
    ..aOS(3, _omitFieldNames ? '' : 'sighashType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignRawTransactionWithWalletRequest clone() => SignRawTransactionWithWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignRawTransactionWithWalletRequest copyWith(void Function(SignRawTransactionWithWalletRequest) updates) => super.copyWith((message) => updates(message as SignRawTransactionWithWalletRequest)) as SignRawTransactionWithWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletRequest create() => SignRawTransactionWithWalletRequest._();
  SignRawTransactionWithWalletRequest createEmptyInstance() => create();
  static $pb.PbList<SignRawTransactionWithWalletRequest> createRepeated() => $pb.PbList<SignRawTransactionWithWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRawTransactionWithWalletRequest>(create);
  static SignRawTransactionWithWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hexString => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexString($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHexString() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexString() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<PreviousTx> get prevTxs => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get sighashType => $_getSZ(2);
  @$pb.TagNumber(3)
  set sighashType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSighashType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSighashType() => clearField(3);
}

class PreviousTx extends $pb.GeneratedMessage {
  factory PreviousTx({
    $core.String? txid,
    $core.int? vout,
    $core.String? scriptPubKey,
    $core.String? redeemScript,
    $core.String? witnessScript,
    $fixnum.Int64? amount,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  PreviousTx._() : super();
  factory PreviousTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PreviousTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviousTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOS(4, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(5, _omitFieldNames ? '' : 'witnessScript')
    ..aInt64(6, _omitFieldNames ? '' : 'amount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PreviousTx clone() => PreviousTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PreviousTx copyWith(void Function(PreviousTx) updates) => super.copyWith((message) => updates(message as PreviousTx)) as PreviousTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviousTx create() => PreviousTx._();
  PreviousTx createEmptyInstance() => create();
  static $pb.PbList<PreviousTx> createRepeated() => $pb.PbList<PreviousTx>();
  @$core.pragma('dart2js:noInline')
  static PreviousTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviousTx>(create);
  static PreviousTx? _defaultInstance;

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
  $core.String get scriptPubKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set scriptPubKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasScriptPubKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptPubKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get redeemScript => $_getSZ(3);
  @$pb.TagNumber(4)
  set redeemScript($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRedeemScript() => $_has(3);
  @$pb.TagNumber(4)
  void clearRedeemScript() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get witnessScript => $_getSZ(4);
  @$pb.TagNumber(5)
  set witnessScript($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWitnessScript() => $_has(4);
  @$pb.TagNumber(5)
  void clearWitnessScript() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amount => $_getI64(5);
  @$pb.TagNumber(6)
  set amount($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);
}

class SignRawTransactionWithWalletResponse extends $pb.GeneratedMessage {
  factory SignRawTransactionWithWalletResponse({
    $core.String? hex,
    $core.bool? complete,
    $core.Iterable<Error>? errors,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    if (complete != null) {
      $result.complete = complete;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    return $result;
  }
  SignRawTransactionWithWalletResponse._() : super();
  factory SignRawTransactionWithWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignRawTransactionWithWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignRawTransactionWithWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..aOB(2, _omitFieldNames ? '' : 'complete')
    ..pc<Error>(3, _omitFieldNames ? '' : 'errors', $pb.PbFieldType.PM, subBuilder: Error.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignRawTransactionWithWalletResponse clone() => SignRawTransactionWithWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignRawTransactionWithWalletResponse copyWith(void Function(SignRawTransactionWithWalletResponse) updates) => super.copyWith((message) => updates(message as SignRawTransactionWithWalletResponse)) as SignRawTransactionWithWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletResponse create() => SignRawTransactionWithWalletResponse._();
  SignRawTransactionWithWalletResponse createEmptyInstance() => create();
  static $pb.PbList<SignRawTransactionWithWalletResponse> createRepeated() => $pb.PbList<SignRawTransactionWithWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRawTransactionWithWalletResponse>(create);
  static SignRawTransactionWithWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get complete => $_getBF(1);
  @$pb.TagNumber(2)
  set complete($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasComplete() => $_has(1);
  @$pb.TagNumber(2)
  void clearComplete() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<Error> get errors => $_getList(2);
}

class Error extends $pb.GeneratedMessage {
  factory Error({
    $core.String? txid,
    $core.int? vout,
    $core.String? scriptSig,
    $core.String? sequence,
    $core.String? error,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (scriptSig != null) {
      $result.scriptSig = scriptSig;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  Error._() : super();
  factory Error.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Error.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Error', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'scriptSig')
    ..aOS(4, _omitFieldNames ? '' : 'sequence')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Error clone() => Error()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Error copyWith(void Function(Error) updates) => super.copyWith((message) => updates(message as Error)) as Error;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Error create() => Error._();
  Error createEmptyInstance() => create();
  static $pb.PbList<Error> createRepeated() => $pb.PbList<Error>();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Error>(create);
  static Error? _defaultInstance;

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
  $core.String get scriptSig => $_getSZ(2);
  @$pb.TagNumber(3)
  set scriptSig($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasScriptSig() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptSig() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get sequence => $_getSZ(3);
  @$pb.TagNumber(4)
  set sequence($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSequence() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequence() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => clearField(5);
}

/// Transaction misc messages
class SendRawTransactionRequest extends $pb.GeneratedMessage {
  factory SendRawTransactionRequest({
    $core.String? hexString,
    $core.double? maxFeeRate,
  }) {
    final $result = create();
    if (hexString != null) {
      $result.hexString = hexString;
    }
    if (maxFeeRate != null) {
      $result.maxFeeRate = maxFeeRate;
    }
    return $result;
  }
  SendRawTransactionRequest._() : super();
  factory SendRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hexString')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'maxFeeRate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendRawTransactionRequest clone() => SendRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendRawTransactionRequest copyWith(void Function(SendRawTransactionRequest) updates) => super.copyWith((message) => updates(message as SendRawTransactionRequest)) as SendRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendRawTransactionRequest create() => SendRawTransactionRequest._();
  SendRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SendRawTransactionRequest> createRepeated() => $pb.PbList<SendRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SendRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendRawTransactionRequest>(create);
  static SendRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hexString => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexString($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHexString() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexString() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get maxFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set maxFeeRate($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxFeeRate() => clearField(2);
}

class SendRawTransactionResponse extends $pb.GeneratedMessage {
  factory SendRawTransactionResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SendRawTransactionResponse._() : super();
  factory SendRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendRawTransactionResponse clone() => SendRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendRawTransactionResponse copyWith(void Function(SendRawTransactionResponse) updates) => super.copyWith((message) => updates(message as SendRawTransactionResponse)) as SendRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendRawTransactionResponse create() => SendRawTransactionResponse._();
  SendRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SendRawTransactionResponse> createRepeated() => $pb.PbList<SendRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SendRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendRawTransactionResponse>(create);
  static SendRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class TestMempoolAcceptRequest extends $pb.GeneratedMessage {
  factory TestMempoolAcceptRequest({
    $core.Iterable<$core.String>? hexStrings,
  }) {
    final $result = create();
    if (hexStrings != null) {
      $result.hexStrings.addAll(hexStrings);
    }
    return $result;
  }
  TestMempoolAcceptRequest._() : super();
  factory TestMempoolAcceptRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'hexStrings')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest clone() => TestMempoolAcceptRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest copyWith(void Function(TestMempoolAcceptRequest) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptRequest)) as TestMempoolAcceptRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest create() => TestMempoolAcceptRequest._();
  TestMempoolAcceptRequest createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptRequest> createRepeated() => $pb.PbList<TestMempoolAcceptRequest>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptRequest>(create);
  static TestMempoolAcceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get hexStrings => $_getList(0);
}

class TestMempoolAcceptResponse extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse({
    $core.String? txid,
    $core.bool? allowed,
    $core.String? rejectReason,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (allowed != null) {
      $result.allowed = allowed;
    }
    if (rejectReason != null) {
      $result.rejectReason = rejectReason;
    }
    return $result;
  }
  TestMempoolAcceptResponse._() : super();
  factory TestMempoolAcceptResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'allowed')
    ..aOS(3, _omitFieldNames ? '' : 'rejectReason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse clone() => TestMempoolAcceptResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse copyWith(void Function(TestMempoolAcceptResponse) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptResponse)) as TestMempoolAcceptResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse create() => TestMempoolAcceptResponse._();
  TestMempoolAcceptResponse createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptResponse> createRepeated() => $pb.PbList<TestMempoolAcceptResponse>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse>(create);
  static TestMempoolAcceptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowed => $_getBF(1);
  @$pb.TagNumber(2)
  set allowed($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAllowed() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowed() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rejectReason => $_getSZ(2);
  @$pb.TagNumber(3)
  set rejectReason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRejectReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearRejectReason() => clearField(3);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? txid,
    $core.bool? includeWatchonly,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (includeWatchonly != null) {
      $result.includeWatchonly = includeWatchonly;
    }
    return $result;
  }
  GetTransactionRequest._() : super();
  factory GetTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'includeWatchonly')
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
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeWatchonly => $_getBF(1);
  @$pb.TagNumber(2)
  set includeWatchonly($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIncludeWatchonly() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeWatchonly() => clearField(2);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    $core.String? txid,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $core.String? blockHash,
    $core.int? blockHeight,
    $fixnum.Int64? amount,
    $fixnum.Int64? fee,
    $core.String? hex,
    $core.Iterable<Detail>? details,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (details != null) {
      $result.details.addAll(details);
    }
    return $result;
  }
  GetTransactionResponse._() : super();
  factory GetTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'blockTime')
    ..aOS(4, _omitFieldNames ? '' : 'blockHash')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'amount')
    ..aInt64(7, _omitFieldNames ? '' : 'fee')
    ..aOS(8, _omitFieldNames ? '' : 'hex')
    ..pc<Detail>(9, _omitFieldNames ? '' : 'details', $pb.PbFieldType.PM, subBuilder: Detail.create)
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
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get confirmations => $_getIZ(1);
  @$pb.TagNumber(2)
  set confirmations($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConfirmations() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmations() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get blockTime => $_getI64(2);
  @$pb.TagNumber(3)
  set blockTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlockTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockTime() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get blockHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set blockHeight($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amount => $_getI64(5);
  @$pb.TagNumber(6)
  set amount($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get fee => $_getI64(6);
  @$pb.TagNumber(7)
  set fee($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearFee() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get hex => $_getSZ(7);
  @$pb.TagNumber(8)
  set hex($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasHex() => $_has(7);
  @$pb.TagNumber(8)
  void clearHex() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<Detail> get details => $_getList(8);
}

class Detail extends $pb.GeneratedMessage {
  factory Detail({
    $core.String? address,
    $core.String? category,
    $fixnum.Int64? amount,
    $core.String? label,
    $core.int? vout,
    $core.double? fee,
    $core.bool? abandoned,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (category != null) {
      $result.category = category;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (label != null) {
      $result.label = label;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (abandoned != null) {
      $result.abandoned = abandoned;
    }
    return $result;
  }
  Detail._() : super();
  factory Detail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Detail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Detail', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisig.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'category')
    ..aInt64(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..aOB(7, _omitFieldNames ? '' : 'abandoned')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Detail clone() => Detail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Detail copyWith(void Function(Detail) updates) => super.copyWith((message) => updates(message as Detail)) as Detail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Detail create() => Detail._();
  Detail createEmptyInstance() => create();
  static $pb.PbList<Detail> createRepeated() => $pb.PbList<Detail>();
  @$core.pragma('dart2js:noInline')
  static Detail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Detail>(create);
  static Detail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get category => $_getSZ(1);
  @$pb.TagNumber(2)
  set category($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get vout => $_getIZ(4);
  @$pb.TagNumber(5)
  set vout($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVout() => $_has(4);
  @$pb.TagNumber(5)
  void clearVout() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get fee => $_getN(5);
  @$pb.TagNumber(6)
  set fee($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFee() => $_has(5);
  @$pb.TagNumber(6)
  void clearFee() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get abandoned => $_getBF(6);
  @$pb.TagNumber(7)
  set abandoned($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAbandoned() => $_has(6);
  @$pb.TagNumber(7)
  void clearAbandoned() => clearField(7);
}

class MultisigServiceApi {
  $pb.RpcClient _client;
  MultisigServiceApi(this._client);

  $async.Future<AddMultisigAddressResponse> addMultisigAddress($pb.ClientContext? ctx, AddMultisigAddressRequest request) =>
    _client.invoke<AddMultisigAddressResponse>(ctx, 'MultisigService', 'AddMultisigAddress', request, AddMultisigAddressResponse())
  ;
  $async.Future<ImportAddressResponse> importAddress($pb.ClientContext? ctx, ImportAddressRequest request) =>
    _client.invoke<ImportAddressResponse>(ctx, 'MultisigService', 'ImportAddress', request, ImportAddressResponse())
  ;
  $async.Future<GetAddressInfoResponse> getAddressInfo($pb.ClientContext? ctx, GetAddressInfoRequest request) =>
    _client.invoke<GetAddressInfoResponse>(ctx, 'MultisigService', 'GetAddressInfo', request, GetAddressInfoResponse())
  ;
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
    _client.invoke<ListUnspentResponse>(ctx, 'MultisigService', 'ListUnspent', request, ListUnspentResponse())
  ;
  $async.Future<ListAddressGroupingsResponse> listAddressGroupings($pb.ClientContext? ctx, ListAddressGroupingsRequest request) =>
    _client.invoke<ListAddressGroupingsResponse>(ctx, 'MultisigService', 'ListAddressGroupings', request, ListAddressGroupingsResponse())
  ;
  $async.Future<CreateRawTransactionResponse> createRawTransaction($pb.ClientContext? ctx, CreateRawTransactionRequest request) =>
    _client.invoke<CreateRawTransactionResponse>(ctx, 'MultisigService', 'CreateRawTransaction', request, CreateRawTransactionResponse())
  ;
  $async.Future<CreatePsbtResponse> createPsbt($pb.ClientContext? ctx, CreatePsbtRequest request) =>
    _client.invoke<CreatePsbtResponse>(ctx, 'MultisigService', 'CreatePsbt', request, CreatePsbtResponse())
  ;
  $async.Future<WalletCreateFundedPsbtResponse> walletCreateFundedPsbt($pb.ClientContext? ctx, WalletCreateFundedPsbtRequest request) =>
    _client.invoke<WalletCreateFundedPsbtResponse>(ctx, 'MultisigService', 'WalletCreateFundedPsbt', request, WalletCreateFundedPsbtResponse())
  ;
  $async.Future<DecodePsbtResponse> decodePsbt($pb.ClientContext? ctx, DecodePsbtRequest request) =>
    _client.invoke<DecodePsbtResponse>(ctx, 'MultisigService', 'DecodePsbt', request, DecodePsbtResponse())
  ;
  $async.Future<AnalyzePsbtResponse> analyzePsbt($pb.ClientContext? ctx, AnalyzePsbtRequest request) =>
    _client.invoke<AnalyzePsbtResponse>(ctx, 'MultisigService', 'AnalyzePsbt', request, AnalyzePsbtResponse())
  ;
  $async.Future<WalletProcessPsbtResponse> walletProcessPsbt($pb.ClientContext? ctx, WalletProcessPsbtRequest request) =>
    _client.invoke<WalletProcessPsbtResponse>(ctx, 'MultisigService', 'WalletProcessPsbt', request, WalletProcessPsbtResponse())
  ;
  $async.Future<CombinePsbtResponse> combinePsbt($pb.ClientContext? ctx, CombinePsbtRequest request) =>
    _client.invoke<CombinePsbtResponse>(ctx, 'MultisigService', 'CombinePsbt', request, CombinePsbtResponse())
  ;
  $async.Future<FinalizePsbtResponse> finalizePsbt($pb.ClientContext? ctx, FinalizePsbtRequest request) =>
    _client.invoke<FinalizePsbtResponse>(ctx, 'MultisigService', 'FinalizePsbt', request, FinalizePsbtResponse())
  ;
  $async.Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ClientContext? ctx, UtxoUpdatePsbtRequest request) =>
    _client.invoke<UtxoUpdatePsbtResponse>(ctx, 'MultisigService', 'UtxoUpdatePsbt', request, UtxoUpdatePsbtResponse())
  ;
  $async.Future<JoinPsbtsResponse> joinPsbts($pb.ClientContext? ctx, JoinPsbtsRequest request) =>
    _client.invoke<JoinPsbtsResponse>(ctx, 'MultisigService', 'JoinPsbts', request, JoinPsbtsResponse())
  ;
  $async.Future<SignRawTransactionWithWalletResponse> signRawTransactionWithWallet($pb.ClientContext? ctx, SignRawTransactionWithWalletRequest request) =>
    _client.invoke<SignRawTransactionWithWalletResponse>(ctx, 'MultisigService', 'SignRawTransactionWithWallet', request, SignRawTransactionWithWalletResponse())
  ;
  $async.Future<SendRawTransactionResponse> sendRawTransaction($pb.ClientContext? ctx, SendRawTransactionRequest request) =>
    _client.invoke<SendRawTransactionResponse>(ctx, 'MultisigService', 'SendRawTransaction', request, SendRawTransactionResponse())
  ;
  $async.Future<TestMempoolAcceptResponse> testMempoolAccept($pb.ClientContext? ctx, TestMempoolAcceptRequest request) =>
    _client.invoke<TestMempoolAcceptResponse>(ctx, 'MultisigService', 'TestMempoolAccept', request, TestMempoolAcceptResponse())
  ;
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
    _client.invoke<GetTransactionResponse>(ctx, 'MultisigService', 'GetTransaction', request, GetTransactionResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
