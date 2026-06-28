//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// MultisigKey is one cosigner key in a group.
class MultisigKey extends $pb.GeneratedMessage {
  factory MultisigKey({
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? isWallet,
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
    if (isWallet != null) {
      $result.isWallet = isWallet;
    }
    return $result;
  }
  MultisigKey._() : super();
  factory MultisigKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'originPath')
    ..aOB(5, _omitFieldNames ? '' : 'isWallet')
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

  /// Extended public key (xpub/tpub).
  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => clearField(1);

  /// Full BIP32 derivation path of the account key, e.g. "m/48'/1'/0'/2'".
  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => clearField(2);

  /// Master key fingerprint, 8 hex chars. Empty for non-wallet keys.
  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => clearField(3);

  /// Origin path without the leading "m/", e.g. "48'/1'/0'/2'". Empty for non-wallet keys.
  @$pb.TagNumber(4)
  $core.String get originPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set originPath($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOriginPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginPath() => clearField(4);

  /// True if this key is owned by the local wallet (emits a [fp/origin] prefix).
  @$pb.TagNumber(5)
  $core.bool get isWallet => $_getBF(4);
  @$pb.TagNumber(5)
  set isWallet($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsWallet() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsWallet() => clearField(5);
}

/// MultisigGroup describes an m-of-n policy.
class MultisigGroup extends $pb.GeneratedMessage {
  factory MultisigGroup({
    $core.int? m,
    $core.int? n,
    $core.Iterable<MultisigKey>? keys,
  }) {
    final $result = create();
    if (m != null) {
      $result.m = m;
    }
    if (n != null) {
      $result.n = n;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  MultisigGroup._() : super();
  factory MultisigGroup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigGroup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigGroup', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'm', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'n', $pb.PbFieldType.OU3)
    ..pc<MultisigKey>(3, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: MultisigKey.create)
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

  /// Threshold (m): signatures required.
  @$pb.TagNumber(1)
  $core.int get m => $_getIZ(0);
  @$pb.TagNumber(1)
  set m($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasM() => $_has(0);
  @$pb.TagNumber(1)
  void clearM() => clearField(1);

  /// Total keys (n).
  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<MultisigKey> get keys => $_getList(2);
}

class BuildDescriptorsRequest extends $pb.GeneratedMessage {
  factory BuildDescriptorsRequest({
    MultisigGroup? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  BuildDescriptorsRequest._() : super();
  factory BuildDescriptorsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BuildDescriptorsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BuildDescriptorsRequest clone() => BuildDescriptorsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BuildDescriptorsRequest copyWith(void Function(BuildDescriptorsRequest) updates) => super.copyWith((message) => updates(message as BuildDescriptorsRequest)) as BuildDescriptorsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsRequest create() => BuildDescriptorsRequest._();
  BuildDescriptorsRequest createEmptyInstance() => create();
  static $pb.PbList<BuildDescriptorsRequest> createRepeated() => $pb.PbList<BuildDescriptorsRequest>();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsRequest>(create);
  static BuildDescriptorsRequest? _defaultInstance;

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

class BuildDescriptorsResponse extends $pb.GeneratedMessage {
  factory BuildDescriptorsResponse({
    $core.String? receiveDescriptor,
    $core.String? changeDescriptor,
  }) {
    final $result = create();
    if (receiveDescriptor != null) {
      $result.receiveDescriptor = receiveDescriptor;
    }
    if (changeDescriptor != null) {
      $result.changeDescriptor = changeDescriptor;
    }
    return $result;
  }
  BuildDescriptorsResponse._() : super();
  factory BuildDescriptorsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BuildDescriptorsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'receiveDescriptor')
    ..aOS(2, _omitFieldNames ? '' : 'changeDescriptor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BuildDescriptorsResponse clone() => BuildDescriptorsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BuildDescriptorsResponse copyWith(void Function(BuildDescriptorsResponse) updates) => super.copyWith((message) => updates(message as BuildDescriptorsResponse)) as BuildDescriptorsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsResponse create() => BuildDescriptorsResponse._();
  BuildDescriptorsResponse createEmptyInstance() => create();
  static $pb.PbList<BuildDescriptorsResponse> createRepeated() => $pb.PbList<BuildDescriptorsResponse>();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsResponse>(create);
  static BuildDescriptorsResponse? _defaultInstance;

  /// Receive descriptor (/0/*) with checksum.
  @$pb.TagNumber(1)
  $core.String get receiveDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set receiveDescriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReceiveDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiveDescriptor() => clearField(1);

  /// Change descriptor (/1/*) with checksum.
  @$pb.TagNumber(2)
  $core.String get changeDescriptor => $_getSZ(1);
  @$pb.TagNumber(2)
  set changeDescriptor($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChangeDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangeDescriptor() => clearField(2);
}

class ValidatePsbtRequest extends $pb.GeneratedMessage {
  factory ValidatePsbtRequest({
    $core.String? psbtBase64,
    $core.int? requiredSigs,
    MultisigGroup? group,
  }) {
    final $result = create();
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  ValidatePsbtRequest._() : super();
  factory ValidatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.OU3)
    ..aOM<MultisigGroup>(3, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidatePsbtRequest clone() => ValidatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidatePsbtRequest copyWith(void Function(ValidatePsbtRequest) updates) => super.copyWith((message) => updates(message as ValidatePsbtRequest)) as ValidatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidatePsbtRequest create() => ValidatePsbtRequest._();
  ValidatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<ValidatePsbtRequest> createRepeated() => $pb.PbList<ValidatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidatePsbtRequest>(create);
  static ValidatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => clearField(1);

  /// Signatures required per input (m).
  @$pb.TagNumber(2)
  $core.int get requiredSigs => $_getIZ(1);
  @$pb.TagNumber(2)
  set requiredSigs($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRequiredSigs() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequiredSigs() => clearField(2);

  /// Optional. When set, every input must match this group's descriptor.
  @$pb.TagNumber(3)
  MultisigGroup get group => $_getN(2);
  @$pb.TagNumber(3)
  set group(MultisigGroup v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroup() => clearField(3);
  @$pb.TagNumber(3)
  MultisigGroup ensureGroup() => $_ensure(2);
}

class ValidatePsbtResponse extends $pb.GeneratedMessage {
  factory ValidatePsbtResponse({
    $core.bool? hasSignatures,
    $core.int? signatureCount,
    $core.bool? isComplete,
    $core.bool? finalizable,
    $core.String? error,
  }) {
    final $result = create();
    if (hasSignatures != null) {
      $result.hasSignatures = hasSignatures;
    }
    if (signatureCount != null) {
      $result.signatureCount = signatureCount;
    }
    if (isComplete != null) {
      $result.isComplete = isComplete;
    }
    if (finalizable != null) {
      $result.finalizable = finalizable;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ValidatePsbtResponse._() : super();
  factory ValidatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasSignatures')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'signatureCount', $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..aOB(4, _omitFieldNames ? '' : 'finalizable')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidatePsbtResponse clone() => ValidatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidatePsbtResponse copyWith(void Function(ValidatePsbtResponse) updates) => super.copyWith((message) => updates(message as ValidatePsbtResponse)) as ValidatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidatePsbtResponse create() => ValidatePsbtResponse._();
  ValidatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<ValidatePsbtResponse> createRepeated() => $pb.PbList<ValidatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidatePsbtResponse>(create);
  static ValidatePsbtResponse? _defaultInstance;

  /// At least one partial signature is present on some input.
  @$pb.TagNumber(1)
  $core.bool get hasSignatures => $_getBF(0);
  @$pb.TagNumber(1)
  set hasSignatures($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasSignatures() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasSignatures() => clearField(1);

  /// Maximum partial-signature count across inputs.
  @$pb.TagNumber(2)
  $core.int get signatureCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set signatureCount($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignatureCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignatureCount() => clearField(2);

  /// Every input has reached the required threshold.
  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => clearField(3);

  /// The PSBT can be finalized into a broadcastable transaction.
  @$pb.TagNumber(4)
  $core.bool get finalizable => $_getBF(3);
  @$pb.TagNumber(4)
  set finalizable($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFinalizable() => $_has(3);
  @$pb.TagNumber(4)
  void clearFinalizable() => clearField(4);

  /// Non-empty on validation failure (e.g. foreign input, parse error).
  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => clearField(5);
}

class MultisigLoungeServiceApi {
  $pb.RpcClient _client;
  MultisigLoungeServiceApi(this._client);

  $async.Future<BuildDescriptorsResponse> buildDescriptors($pb.ClientContext? ctx, BuildDescriptorsRequest request) =>
    _client.invoke<BuildDescriptorsResponse>(ctx, 'MultisigLoungeService', 'BuildDescriptors', request, BuildDescriptorsResponse())
  ;
  $async.Future<ValidatePsbtResponse> validatePsbt($pb.ClientContext? ctx, ValidatePsbtRequest request) =>
    _client.invoke<ValidatePsbtResponse>(ctx, 'MultisigLoungeService', 'ValidatePsbt', request, ValidatePsbtResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
